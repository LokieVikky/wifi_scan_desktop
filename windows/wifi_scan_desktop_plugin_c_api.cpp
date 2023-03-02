#include "include/wifi_scan_desktop/wifi_scan_desktop_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "wifi_scan_desktop_plugin.h"

void WifiScanDesktopPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  wifi_scan_desktop::WifiScanDesktopPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
