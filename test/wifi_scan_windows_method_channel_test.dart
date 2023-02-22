import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:wifi_scan_windows/wifi_scan_windows_method_channel.dart';

void main() {
  // MethodChannelWifiScanWindows platform = MethodChannelWifiScanWindows();
  const MethodChannel channel = MethodChannel('wifi_scan_windows');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
