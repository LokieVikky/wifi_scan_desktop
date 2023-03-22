import 'dart:core';

import 'package:flutter/material.dart';
import 'package:wifi_scan_desktop/wifi_info.dart';
import 'package:wifi_scan_desktop/wifi_scan_desktop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<WifiInfo> availableNetworks = [];
  final WifiScanDesktop _wifiScanDesktopPlugin = WifiScanDesktop();

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
                  List<WifiInfo>? result =
                      await _wifiScanDesktopPlugin.getAvailableNetworks();
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
                    subtitle: Text('Channel Number: ${availableNetworks[index].channelNo}'),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              _wifiScanDesktopPlugin.performScan((data) async {
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
