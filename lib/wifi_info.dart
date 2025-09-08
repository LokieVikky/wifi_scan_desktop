/// Model to store Scanned WifiInfo
class WifiInfo {
  ///
  final String? authAlgorithm;
  final String? bssNetworkType;
  final bool? connectable;
  final String? defaultCipherAlgorithm;
  final String? flags;
  /// numberOfBssid present int the Scanned Network
  final int? numberOfBssid;
  /// numberOfPhyTypes Supported by the Scanned Network
  final int? numberOfPhyTypesSupported;
  /// physical type of the network
  final String? bssPhyType;
  /// Profile name of the Scanned Network
  final String? profileName;
  /// RSSI value of the Scanned Network
  final int? rssi;
  /// SSID of the Scanned Network
  final String? ssid;
  /// BSSID of the Scanned Network
  final String? bssid;
  /// true if security is enabled
  final bool? securityEnabled;
  /// Channel number of the network
  final int? channelNo;
  /// The value is in MHz.
  final int? frequency;
  /// Ranges from 0 to 100
  final int? signalQuality;

  /// Returns a new Instance WifiInfo
  WifiInfo({
    this.authAlgorithm,
    this.bssNetworkType,
    this.connectable,
    this.defaultCipherAlgorithm,
    this.flags,
    this.numberOfBssid,
    this.numberOfPhyTypesSupported,
    this.bssPhyType,
    this.profileName,
    this.rssi,
    this.ssid,
    this.bssid,
    this.securityEnabled,
    this.channelNo,
    this.frequency,
    this.signalQuality,
  });
}
