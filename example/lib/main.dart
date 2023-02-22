import 'dart:core';

import 'package:flutter/material.dart';
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
  List<AvailableNetwork> availableNetworks = [];
  final WifiScanWindows _wifiScanWindowsPlugin = WifiScanWindows();

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
                  setState(() {
                    availableNetworks = result ?? [];
                  });
                },
                child: const Text("Get networks")),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: availableNetworks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('SSID: ${availableNetworks[index].ssid}'),
                    subtitle: Text('RSSI: ${availableNetworks[index].rssi}'),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              _wifiScanWindowsPlugin.performScan((data) async {
                debugPrint("Scan Completed $data");
              }, (error) {
                debugPrint(error);
              });
            },
            label: const Text('Scan')),
      ),
    );
  }
}
