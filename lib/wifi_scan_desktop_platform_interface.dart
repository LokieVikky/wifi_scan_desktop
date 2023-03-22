import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_scan_desktop/wifi_scan_desktop_method_channel.dart';

abstract class WifiScanDesktopPlatform extends PlatformInterface {
  /// Constructs a WifiScanWindowsPlatform.
  WifiScanDesktopPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiScanDesktopPlatform _instance = MethodChannelWifiScanDesktop();

  /// The default instance of [WifiScanDesktopPlatform] to use.
  ///
  /// Defaults to [MethodChannelWifiScanDesktop].
  static WifiScanDesktopPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiScanDesktopPlatform] when
  /// they register themselves.
  static set instance(WifiScanDesktopPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// This will be used to throw error on other unsupported platforms
  Future<String?> getAvailableNetworks() {
    throw UnimplementedError(
        'getAvailableNetworks() has not been implemented.');
  }

  /// This will be used to throw error on other unsupported platforms
  void performScan(
      Function(dynamic) onScanCompleted, Function(dynamic) onScanError) {
    throw UnimplementedError('performScan() has not been implemented.');
  }
}
