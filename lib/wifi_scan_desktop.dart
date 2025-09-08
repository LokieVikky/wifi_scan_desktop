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
                authAlgorithm: e['AuthAlgorithm'],
                bssNetworkType: e['BSSNetworkType'],
                connectable: e['Connectable'] == "Yes",
                defaultCipherAlgorithm: e['DefaultCipherAlgorithm'],
                flags: e['Flags'],
                numberOfBssid: int.tryParse(e['NumberOfBSSID'] ?? ''),
                numberOfPhyTypesSupported: int.tryParse(e['NumberOfPHYTypesSupported'] ?? ''),
                bssPhyType: e['BssPhyType'],
                profileName: e['ProfileName'],
                rssi: int.tryParse(e['RSSI'] ?? ''),
                ssid: e['SSID'],
                bssid: e['BSSID'],
                securityEnabled: e['SecurityEnabled'] == "Yes",
                channelNo: int.tryParse(e['ChannelNumber'] ?? ''),
                frequency: int.tryParse(e['Frequency'] ?? ''),
                signalQuality: int.tryParse(e['SignalQuality'] ?? ''),
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
