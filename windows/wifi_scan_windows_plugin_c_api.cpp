#include "include/wifi_scan_windows/wifi_scan_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "wifi_scan_windows_plugin.h"

void WifiScanWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  wifi_scan_windows::WifiScanWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
