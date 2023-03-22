import 'dart:convert';

import 'package:wifi_scan_desktop/wifi_info.dart';
import 'package:wifi_scan_desktop/wifi_scan_desktop_platform_interface.dart';

class WifiScanDesktop {
  /// This will parse the scanner results to WifiInfo Model
  Future<List<WifiInfo>?> getAvailableNetworks() async {
    try {
      String? nativeResult = await WifiScanDesktopPlatform.instance.getAvailableNetworks();
      if (nativeResult == null) {
        throw Exception("Unknown error occurred");
      }
      dynamic scanResultJson = jsonDecode(nativeResult);
      if (scanResultJson.runtimeType is Map) {
        throw Exception("${scanResultJson["Error"]}");
      }

      return (scanResultJson as List)
          .map((e) => WifiInfo(
                e['AuthAlgorithm'],
                e['BSSNetworkType'],
                e['Connectable'] == "Yes",
                e['DefaultCipherAlgorithm'],
                e['Flags'],
                int.tryParse(e['NumberOfBSSID'] ?? ''),
                int.tryParse(e['NumberOfPHYTypesSupported'] ?? ''),
                e['ProfileName'],
                int.tryParse(e['RSSI'] ?? ''),
                e['SSID'],
                e['SecurityEnabled'] == "Yes",
                int.tryParse(e['ChannelNumber'] ?? ''),
                int.tryParse(e['SignalQuality'] ?? ''),
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Used to perform a new scan
  void performScan(Function(dynamic) onScanCompleted, Function(dynamic) onScanError) {
    try {
      WifiScanDesktopPlatform.instance.performScan(onScanCompleted, onScanError);
    } catch (e) {
      rethrow;
    }
  }
}
