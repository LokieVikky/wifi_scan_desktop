import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wifi_scan_windows_method_channel.dart';

abstract class WifiScanWindowsPlatform extends PlatformInterface {
  /// Constructs a WifiScanWindowsPlatform.
  WifiScanWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiScanWindowsPlatform _instance = MethodChannelWifiScanWindows();

  /// The default instance of [WifiScanWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelWifiScanWindows].
  static WifiScanWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiScanWindowsPlatform] when
  /// they register themselves.
  static set instance(WifiScanWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getAvailableNetworks(){
    throw UnimplementedError('getAvailableNetworks() has not been implemented.');
  }

  void performScan(Function(dynamic) onScanCompleted, Function(dynamic) onScanError){
    throw UnimplementedError('performScan() has not been implemented.');
  }
}
