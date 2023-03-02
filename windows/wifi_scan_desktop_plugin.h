#ifndef FLUTTER_PLUGIN_WIFI_SCAN_DESKTOP_PLUGIN_H_
#define FLUTTER_PLUGIN_WIFI_SCAN_DESKTOP_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace wifi_scan_desktop {

class WifiScanDesktopPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WifiScanDesktopPlugin();

  virtual ~WifiScanDesktopPlugin();

  // Disallow copy and assign.
  WifiScanDesktopPlugin(const WifiScanDesktopPlugin&) = delete;
  WifiScanDesktopPlugin& operator=(const WifiScanDesktopPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace wifi_scan_desktop

#endif  // FLUTTER_PLUGIN_WIFI_SCAN_DESKTOP_PLUGIN_H_
