<?code-excerpt path-base="excerpts/packages/url_launcher_example"?>

# wifi_scan_desktop

[![pub package](https://img.shields.io/pub/v/wifi_scan_desktop.svg)](https://pub.dev/packages/wifi_scan_desktop)

This plugin allows Flutter apps to scan for nearby visible WiFi access points in Windows and macOS

## Usage

To use this plugin, add `wifi_scan_desktop` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

### Start scan
You can trigger full WiFi scan with `performScan` API, as shown below:
```dart
void _scan() async {
   WifiScanDesktop _wifiScanDesktopPlugin = WifiScanDesktop();
  // start full scan async-ly
   _wifiScanDesktopPlugin.performScan((data) async {
    // scan completed 
  }, (error) {
    // scan completed with error
  });
}
```

### Get scanned results
You can get scanned results with `getAvailableNetworks` API, as shown below:
> **_NOTE:_**  This API can also be used separately which retrieves the list of available networks on a wireless LAN interface.
```dart
void _getAvailableNetworks() async {
  // get scanned results
  List<AvailableNetwork>? result = await _wifiScanDesktopPlugin.getAvailableNetworks();
  
}
```

## Issues and feedback

Please file WiFiFlutter specific issues, bugs, or feature requests in our [issue tracker][wf_issue].

<!-- links -->
[wf_issue]: https://github.com/LokieVikky/wifi_scan_desktop/issues/new
