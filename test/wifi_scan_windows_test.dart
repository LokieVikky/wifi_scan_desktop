import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_scan_windows/wifi_scan_windows.dart';
import 'package:wifi_scan_windows/wifi_scan_windows_platform_interface.dart';
import 'package:wifi_scan_windows/wifi_scan_windows_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWifiScanWindowsPlatform
    with MockPlatformInterfaceMixin
    implements WifiScanWindowsPlatform {




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
  final WifiScanWindowsPlatform initialPlatform = WifiScanWindowsPlatform.instance;

  test('$MethodChannelWifiScanWindows is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWifiScanWindows>());
  });

}
