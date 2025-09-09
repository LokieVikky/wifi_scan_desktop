#include "wifi_scan_desktop_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include <iostream>
#include <adhoc.h>
#include <dot1x.h>
#include <wlanapi.h>
#ifndef UNICODE
#define UNICODE
#endif
#include <stdio.h>
#include <vector>
#include <string>
#include <map>
#include <flutter/event_sink.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include "nlohmann.cpp"

using json = nlohmann::json;
using namespace std;
#pragma comment(lib, "Wlanapi.lib")

DWORD dwMaxClient = 2; //
DWORD dwCurVersion = 0;
std::unique_ptr<flutter::EventSink<>> event_sink_;

namespace wifi_scan_desktop {
    // Scan Callback
    void FuncWlanAcmNotify(PWLAN_NOTIFICATION_DATA data, PVOID context)
    {
        bool& scanning = *(bool*)context;
        if (data->NotificationCode == wlan_notification_acm_scan_complete)
        {
            event_sink_->Success("Scan Success");
            scanning = false;
        }

        if (data->NotificationCode == wlan_notification_acm_scan_fail)
        {
            event_sink_->Error("Scan Error");
            scanning = false;
        }
        // https://learn.microsoft.com/en-us/windows/win32/api/wlanapi/nf-wlanapi-wlanregisternotification#remarks
        // Don't call WlanRegisterNotification from a callback function, a deadlock may occur.
    }

    // Converts wchar to string
    std::string wchar2string(wchar_t *str)
    {
        std::string mystring;
        while (*str)
            mystring += (char)*str++;
        return mystring;
    }

    // https://github.com/torvalds/linux/blob/master/net/wireless/util.c#L141
    int ieee80211_freq_khz_to_channel(ULONG freq)
    {
        // freq = KHZ_TO_MHZ(freq);
        freq = freq / 1000;

        /* see 802.11 17.3.8.3.2 and Annex J */
        if (freq == 2484)
            return 14;
        else if (freq < 2484)
            return (freq - 2407) / 5;
        else if (freq >= 4910 && freq <= 4980)
            return (freq - 4000) / 5;
        else if (freq < 5925)
            return (freq - 5000) / 5;
        else if (freq == 5935)
            return 2;
        else if (freq <= 45000) /* DMG band lower limit */
            /* see 802.11ax D6.1 27.3.22.2 */
            return (freq - 5950) / 5;
        else if (freq >= 58320 && freq <= 70200)
            return (freq - 56160) / 2160;
        else
            return 0;
    }

    // Return Cached Networks
    // TODO throw may prevent free memory
    string getAvailableNetworks()
    {
        HANDLE hClient = NULL;
        PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
        PWLAN_BSS_LIST pBssList = NULL;
        PWLAN_BSS_ENTRY pBssEntry = NULL;
        PWLAN_INTERFACE_INFO pIfInfo = NULL;

        DWORD dw = WlanOpenHandle(dwMaxClient, NULL, &dwCurVersion, &hClient);
        if (dw != ERROR_SUCCESS)
        {
            throw "Error: WlanOpenHandle Failed " + dw;
        }
        DWORD dw1 = WlanEnumInterfaces(hClient, NULL, &pIfList);
        if (dw1 != ERROR_SUCCESS)
        {
            throw "Error: WlanEnumInterfaces Failed " + dw1;
        }
        if (pIfList->dwNumberOfItems > 0)
        {
            pIfInfo = (WLAN_INTERFACE_INFO *)&pIfList->InterfaceInfo[0];
        }
        else
        {
            throw "Error: WlanEnumInterfacesEmpty " + dw1;
        }

        DWORD dw4 = WlanGetNetworkBssList(hClient, &pIfInfo->InterfaceGuid, NULL, dot11_BSS_type_any, TRUE, NULL, &pBssList);
        if (dw4 != ERROR_SUCCESS)
        {
            throw "Error: WlanGetNetworkBssList Failed " + dw4;
        }

        json network_list = json::array();

        for (unsigned int j = 0; j < pBssList->dwNumberOfItems; j++)
        {
            pBssEntry = 
                (WLAN_BSS_ENTRY *)&pBssList->wlanBssEntries[j];

            json values;

            // SSID
            if (pBssEntry->dot11Ssid.uSSIDLength == 0)
            {
                values["SSID"] = "";
            }
            else
            {
                string ssid;
                for (unsigned int k = 0; k < pBssEntry->dot11Ssid.uSSIDLength; k++)
                {
                    ssid = ssid + char((int)pBssEntry->dot11Ssid.ucSSID[k]);
                }
                values["SSID"] = ssid;
            }

            // BSSID
            char bssid[18];
            sprintf_s(bssid, "%02x:%02x:%02x:%02x:%02x:%02x",
                pBssEntry->dot11Bssid[0],
                pBssEntry->dot11Bssid[1],
                pBssEntry->dot11Bssid[2],
                pBssEntry->dot11Bssid[3],
                pBssEntry->dot11Bssid[4],
                pBssEntry->dot11Bssid[5]);
            values["BSSID"] = bssid;

            // BSSNetworkType
            values["BSSNetworkType"] = to_string(pBssEntry->dot11BssType);

            // BssPhyType
            string bssPhyType;
            switch (pBssEntry->dot11BssPhyType)
            {
                case 4:
                    bssPhyType = "a";
                    break;
                case 5:
                    bssPhyType = "b";
                    break;
                case 6:
                    bssPhyType = "g";
                    break;
                case 7:
                    bssPhyType = "n";
                    break;
                case 8:
                    bssPhyType = "ac";
                    break;
                case 9:
                    bssPhyType = "ad";
                    break;
                case 10:
                    bssPhyType = "ax";
                    break;
                case 11:
                    bssPhyType = "be";
                    break;
                default:
                    bssPhyType = "unknown";
                    break;
            }
            values["BssPhyType"] = bssPhyType;

            // RSSI
            LONG rssi = pBssEntry->lRssi;
            values["RSSI"] = to_string(pBssEntry->lRssi);

            // Signal Quality
            int quality;
            if (rssi <= -100)
            {
                quality = 0;
            }
            else if (rssi >= -50)
            {
                quality = 100;
            }
            else
            {
                quality = 2 * (rssi + 100);
            }
            values["SignalQuality"] = to_string(quality);

            // Frequency MHz
            ULONG frequencyKhz = pBssEntry->ulChCenterFrequency;
            values["Frequency"] = to_string(frequencyKhz / 1000);

            // ChannelNumber
            values["ChannelNumber"] = to_string(ieee80211_freq_khz_to_channel(frequencyKhz));

            // Security Enabled
            if ((pBssEntry->usCapabilityInformation & (1 << 4)) != 0)
                values["SecurityEnabled"] = "Yes";
            else
                values["SecurityEnabled"] = "No";

            network_list.push_back(values);
        }

        if (pIfList != NULL) {
            WlanFreeMemory(pIfList);
            pIfList = NULL;
        }

        if (pBssList != NULL) {
            WlanFreeMemory(pBssList);
            pBssList = NULL;
        }

        if (hClient != NULL) {
            WlanCloseHandle(hClient, NULL);
            hClient = NULL;
        }

        return network_list.dump();
    }

    // Calling this will perform a new scan
    void scan()
    {
        HANDLE hClient = NULL;
        PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
        PWLAN_INTERFACE_INFO pIfInfo = NULL;

        DWORD dw = WlanOpenHandle(dwMaxClient, NULL, &dwCurVersion, &hClient);
        if (dw != ERROR_SUCCESS)
        {
            throw "Error: WlanOpenHandle Failed " + dw;
        }
        DWORD dw1 = WlanEnumInterfaces(hClient, NULL, &pIfList);
        if (dw1 != ERROR_SUCCESS)
        {
            throw "Error: WlanEnumInterfaces Failed " + dw1;
        }
        if (pIfList->dwNumberOfItems > 0)
        {
            pIfInfo = (WLAN_INTERFACE_INFO *)&pIfList->InterfaceInfo[0];
        }
        else
        {
            throw "Error: WlanEnumInterfacesEmpty " + dw1;
        }

        if (pIfList != NULL) {
            WlanFreeMemory(pIfList);
            pIfList = NULL;
        }

        bool scanning = true;

        DWORD hResult = WlanRegisterNotification(hClient,
                                                 WLAN_NOTIFICATION_SOURCE_ACM,
                                                 FALSE,
                                                 (WLAN_NOTIFICATION_CALLBACK)FuncWlanAcmNotify,
                                                 &scanning,
                                                 NULL,
                                                 NULL);
        if (hResult != ERROR_SUCCESS)
        {
            throw "Error: WlanRegisterNotification Failed " + hResult;
        }

        DWORD dw3 = WlanScan(hClient, &pIfInfo->InterfaceGuid, NULL, NULL, NULL);
        if (dw3 != ERROR_SUCCESS)
        {
            throw "Error: WlanScan Failed " + dw3;
        }

        // TODO stop if timeout?
        while (scanning) {
            Sleep(100);
        }

        WlanRegisterNotification(hClient,
            WLAN_NOTIFICATION_SOURCE_NONE,
            FALSE,
            NULL,
            NULL,
            NULL,
            NULL);
        WlanCloseHandle(hClient, NULL);
    }

// static
void WifiScanDesktopPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "get_available_networks",
                &flutter::StandardMethodCodec::GetInstance());

        auto eventChannel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
            registrar->messenger(), "scan_callback",
            &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<WifiScanDesktopPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        eventChannel->SetStreamHandler(
            std::make_unique<flutter::StreamHandlerFunctions<>>(
                [plugin_pointer = plugin.get()](auto arguments, auto events)
                {
                    event_sink_ = std::move(events);
                    // plugin_pointer->OnStreamListen(std::move(events));
                    return nullptr;
                },
                [plugin_pointer = plugin.get()](auto arguments)
                {
                    event_sink_ = nullptr;
                    // plugin_pointer->OnStreamCancel();
                    return nullptr;
                }));

        registrar->AddPlugin(std::move(plugin));
}

    // Stream handler functions
    void OnStreamListen(std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
    {
        event_sink_ = std::move(events);
    }

    // Stream handler functions
    void OnStreamCancel() { event_sink_ = nullptr; }

WifiScanDesktopPlugin::WifiScanDesktopPlugin() {}

WifiScanDesktopPlugin::~WifiScanDesktopPlugin() {}

// Method channel that will will called from flutter
void WifiScanDesktopPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name() == "scan")
        {
            try
            {
                scan();
                result->Success();
            }
            catch (const char* error)
            {
                result->Error(error);
            }
        }
        else if(method_call.method_name() == "getAvailableNetworks")
        {
            try
            {
                string available_networks = getAvailableNetworks();
                result->Success(available_networks);
            }
            catch (const char* error)
            {
                result->Error(error);
            }
        }
        else
        {
            result->NotImplemented();
        }
}

}  // namespace wifi_scan_desktop
