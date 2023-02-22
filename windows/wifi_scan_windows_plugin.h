#ifndef FLUTTER_PLUGIN_WIFI_SCAN_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_WIFI_SCAN_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace wifi_scan_windows {

class WifiScanWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WifiScanWindowsPlugin();

  virtual ~WifiScanWindowsPlugin();

  // Disallow copy and assign.
  WifiScanWindowsPlugin(const WifiScanWindowsPlugin&) = delete;
  WifiScanWindowsPlugin& operator=(const WifiScanWindowsPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace wifi_scan_windows

#endif  // FLUTTER_PLUGIN_WIFI_SCAN_WINDOWS_PLUGIN_H_
