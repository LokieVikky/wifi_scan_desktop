import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wifi_scan_windows/available_network.dart';
import 'package:wifi_scan_windows/wifi_scan_windows.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _scannedNetworks = '';
  final _wifiScanWindowsPlugin = WifiScanWindows();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  List<AvailableNetwork>? result =
                      await _wifiScanWindowsPlugin.getAvailableNetworks();
                  print(result?.length);
                },
                child: Text("Get networks")),
          ],
        ),
        body: Column(
          children: [Text(_scannedNetworks)],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              _wifiScanWindowsPlugin.performScan((data) async {
                print("Scan Completed $data");
              }, (error) {
                print(error);
              });
            },
            label: Text('Scan')),
      ),
    );
  }
}
