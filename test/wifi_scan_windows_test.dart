import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_scan_desktop/wifi_scan_desktop_method_channel.dart';
import 'package:wifi_scan_desktop/wifi_scan_desktop_platform_interface.dart';

class MockWifiScanWindowsPlatform
    with MockPlatformInterfaceMixin
    implements WifiScanDesktopPlatform {
  @override
  Future<String?> getAvailableNetworks() {
    // TODO: implement getAvailableNetworks
    throw UnimplementedError();
  }

  @override
  void performScan(Function onScanCompleted, Function(dynamic p1) onScanError) {
    // TODO: implement performScan
  }
}

void main() {
  final WifiScanDesktopPlatform initialPlatform =
      WifiScanDesktopPlatform.instance;

  test('$MethodChannelWifiScanDesktop is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWifiScanDesktop>());
  });
}
