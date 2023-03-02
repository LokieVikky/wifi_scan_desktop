// Model to store Scanned WifiInfo
class WifiInfo {
  final String? authAlgorithm;
  final String? bssNetworkType;
  final bool? connectable;
  final String? defaultCipherAlgorithm;
  final String? flags;
  final int? numberOfBssid;
  final int? numberOfPhyTypesSupported;
  final String? profileName;
  final int? rssi;
  final String? ssid;
  final bool? securityEnabled;
  final int? signalQuality;

  WifiInfo(
      this.authAlgorithm,
      this.bssNetworkType,
      this.connectable,
      this.defaultCipherAlgorithm,
      this.flags,
      this.numberOfBssid,
      this.numberOfPhyTypesSupported,
      this.profileName,
      this.rssi,
      this.ssid,
      this.securityEnabled,
      this.signalQuality);
}
