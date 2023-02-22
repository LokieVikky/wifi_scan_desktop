import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wifi_scan_windows_platform_interface.dart';

/// An implementation of [WifiScanWindowsPlatform] that uses method channels.
class MethodChannelWifiScanWindows extends WifiScanWindowsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel('get_available_networks');

  @visibleForTesting
  static const EventChannel eventChannel = EventChannel('scan_callback');

  @override
  void performScan(Function(dynamic) onScanCompleted, Function(dynamic) onScanError) {
    try {
      eventChannel.receiveBroadcastStream().listen(onScanCompleted, onError: onScanError);
      methodChannel.invokeMethod<String>('scan');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getAvailableNetworks() async {
    try {
      String? availableNetworks = await methodChannel.invokeMethod<String>('getAvailableNetworks');
      return availableNetworks;
    } catch (e) {
      rethrow;
    }
  }
}
