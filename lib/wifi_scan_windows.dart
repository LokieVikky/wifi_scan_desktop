import 'dart:convert';

import 'package:wifi_scan_windows/available_network.dart';

import 'wifi_scan_windows_platform_interface.dart';

class WifiScanWindows {
  Future<List<AvailableNetwork>?> getAvailableNetworks() async {
    try {
      String? nativeResult = await WifiScanWindowsPlatform.instance.getAvailableNetworks();
      if (nativeResult == null) {
        throw Exception("Unknown error occurred");
      }
      dynamic scanResultJson = jsonDecode(nativeResult);
      if (scanResultJson.runtimeType is Map) {
        throw Exception("${scanResultJson["Error"]}");
      }

      return (scanResultJson as List)
          .map((e) => AvailableNetwork(
                e['AuthAlogorithm'],
                e['BSSNetworkType'],
                e['Connectable'] == "Yes",
                e['DefaultCipherAlgorithm'],
                e['Flags'],
                int.tryParse(e['NumberOfBSSID']),
                int.tryParse(e['NumberOfPHYTypesSupported']),
                e['ProfileName'],
                int.tryParse(e['RSSI']),
                e['SSID'],
                e['SecurityEnabled'] == "Yes",
                int.tryParse(e['SignalQuality']),
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  void performScan(Function(dynamic) onScanCompleted, Function(dynamic) onScanError) {
    try {
      WifiScanWindowsPlatform.instance.performScan(onScanCompleted, onScanError);
    } catch (e) {
      rethrow;
    }
  }
}
