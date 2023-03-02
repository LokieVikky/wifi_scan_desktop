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

HANDLE hClient = NULL;
DWORD dwMaxClient = 2; //
DWORD dwCurVersion = 0;
PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
PWLAN_AVAILABLE_NETWORK_LIST pBssList = NULL;
PWLAN_AVAILABLE_NETWORK pBssEntry = NULL;
PWLAN_INTERFACE_INFO pIfInfo = NULL;
int iRSSI = 0;
std::unique_ptr<flutter::EventSink<>> event_sink_;

namespace wifi_scan_desktop {

    void FuncWlanAcmNotify(PWLAN_NOTIFICATION_DATA data, PVOID context)
    {
        if (data->NotificationCode == wlan_notification_acm_scan_complete)
        {
            event_sink_->Success("Scan Success");
        }

        if (data->NotificationCode == wlan_notification_acm_scan_fail)
        {
            event_sink_->Error("Scan Error");
        }
        WlanRegisterNotification(hClient,
                                 WLAN_NOTIFICATION_SOURCE_NONE,
                                 TRUE,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
		WlanCloseHandle(hClient,NULL);
		WlanFreeMemory(pIfList);
    }

    std::string wchar2string(wchar_t *str)
    {
        std::string mystring;
        while (*str)
            mystring += (char)*str++;
        return mystring;
    }

    string getAvailableNetworks()
    {
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

        DWORD dw4 = WlanGetAvailableNetworkList(hClient, &pIfInfo->InterfaceGuid, WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES, NULL, &pBssList);
        if (dw4 != ERROR_SUCCESS)
        {
            throw "Error: WlanGetAvailableNetworkList Failed " + dw4;
        }

        json network_list = json::array();
        for (unsigned int j = 0; j < pBssList->dwNumberOfItems; j++)
        {
            pBssEntry =
                (WLAN_AVAILABLE_NETWORK *)&pBssList->Network[j];

            json values;

            // ProfileName
            // wstring ws(pBssEntry->strProfileName);
            // string str(ws.begin(), ws.end());
            values["ProfileName"] = wchar2string(pBssEntry->strProfileName);

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

            // BSSNetworkType
            values["BSSNetworkType"] = to_string(pBssEntry->dot11BssType);

            // NumberOfBSSID
            values["NumberOfBSSID"] = to_string(pBssEntry->uNumberOfBssids);

            // Connectable
            if (pBssEntry->bNetworkConnectable)
                values["Connectable"] = "Yes";
            else
            {
                values["Connectable"] = "NO";
            }

            // NumberOfPHYTypesSupported
            values["NumberOfPHYTypesSupported"] = to_string(pBssEntry->uNumberOfPhyTypes);

            // RSSI
            if (pBssEntry->wlanSignalQuality == 0)
                iRSSI = -100;
            else if (pBssEntry->wlanSignalQuality == 100)
                iRSSI = -50;
            else
                iRSSI = -100 + (pBssEntry->wlanSignalQuality / 2);

            values["RSSI"] = to_string(iRSSI);

            // Signal Quality
            values["SignalQuality"] = to_string(pBssEntry->wlanSignalQuality);

            // Security Enabled
            if (pBssEntry->bSecurityEnabled)
                values["SecurityEnabled"] = "Yes";
            else
                values["SecurityEnabled"] = "No";

            // AuthAlgorithm
            switch (pBssEntry->dot11DefaultAuthAlgorithm)
            {
            case DOT11_AUTH_ALGO_80211_OPEN:
                values["AuthAlgorithm"] = "802.11 Open";
                break;
            case DOT11_AUTH_ALGO_80211_SHARED_KEY:
                values["AuthAlgorithm"] = "802.11 Shared";
                break;
            case DOT11_AUTH_ALGO_WPA:
                values["AuthAlgorithm"] = "WPA";
                break;
            case DOT11_AUTH_ALGO_WPA_PSK:
                values["AuthAlgorithm"] = "WPA-PSK";
                break;
            case DOT11_AUTH_ALGO_WPA_NONE:
                values["AuthAlgorithm"] = "WPA-None";
                break;
            case DOT11_AUTH_ALGO_RSNA:
                values["AuthAlgorithm"] = "RSNA";
                break;
            case DOT11_AUTH_ALGO_RSNA_PSK:
                values["AuthAlgorithm"] = "RSNA with PSK";
                break;
            default:
                values["AuthAlgorithm"] = "Other";
                break;
            }

            // DefaultCipherAlgorithm
            switch (pBssEntry->dot11DefaultCipherAlgorithm)
            {
            case DOT11_CIPHER_ALGO_NONE:
                values["DefaultCipherAlgorithm"] = "None";
                break;
            case DOT11_CIPHER_ALGO_WEP40:
                values["DefaultCipherAlgorithm"] = "WEP-40";
                break;
            case DOT11_CIPHER_ALGO_TKIP:
                values["DefaultCipherAlgorithm"] = "TKIP";
                break;
            case DOT11_CIPHER_ALGO_CCMP:
                values["DefaultCipherAlgorithm"] = "CCMP";
                break;
            case DOT11_CIPHER_ALGO_WEP104:
                values["DefaultCipherAlgorithm"] = "WEP-104";
                break;
            case DOT11_CIPHER_ALGO_WEP:
                values["DefaultCipherAlgorithm"] = "WEP";
                break;
            default:
                values["DefaultCipherAlgorithm"] = "Other";
                break;
            }

            // Flags
            if (pBssEntry->dwFlags)
            {
                if (pBssEntry->dwFlags & WLAN_AVAILABLE_NETWORK_CONNECTED)
                    values["Flags"] = to_string(pBssEntry->dwFlags) + " - Currenlty connected";
                if (pBssEntry->dwFlags & WLAN_AVAILABLE_NETWORK_HAS_PROFILE)
                    values["Flags"] = to_string(pBssEntry->dwFlags) + " - Has profile";
            }
            network_list.push_back(values);
        }

        return network_list.dump();
    }

    void scan()
    {
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

        DWORD hResult = WlanRegisterNotification(hClient,
                                                 WLAN_NOTIFICATION_SOURCE_ACM,
                                                 FALSE,
                                                 (WLAN_NOTIFICATION_CALLBACK)FuncWlanAcmNotify,
                                                 NULL,
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

    void OnStreamListen(std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
    {
        event_sink_ = std::move(events);
    }

    void OnStreamCancel() { event_sink_ = nullptr; }

WifiScanDesktopPlugin::WifiScanDesktopPlugin() {}

WifiScanDesktopPlugin::~WifiScanDesktopPlugin() {}

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
            catch (string error)
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
            catch (string error)
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
