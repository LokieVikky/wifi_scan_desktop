import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wifi_scan_desktop/wifi_scan_desktop_platform_interface.dart';

/// An implementation of [WifiScanDesktopPlatform] that uses method channels.
class MethodChannelWifiScanDesktop extends WifiScanDesktopPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const MethodChannel methodChannel =
      MethodChannel('get_available_networks');

  @visibleForTesting
  static const EventChannel eventChannel = EventChannel('scan_callback');

  // This will perform a new Scan
  @override
  void performScan(
      Function(dynamic) onScanCompleted, Function(dynamic) onScanError) {
    try {
      eventChannel
          .receiveBroadcastStream()
          .listen(onScanCompleted, onError: onScanError);
      methodChannel.invokeMethod<String>('scan');
    } catch (e) {
      rethrow;
    }
  }

  // Returns cached scan results, works even without performing scan
  @override
  Future<String?> getAvailableNetworks() async {
    try {
      String? availableNetworks =
          await methodChannel.invokeMethod<String>('getAvailableNetworks');
      return availableNetworks;
    } catch (e) {
      rethrow;
    }
  }
}
