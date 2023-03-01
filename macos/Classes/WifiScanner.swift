import CoreWLAN
import CoreLocation

enum ScanError: Error {
  case failedToGetWifiInterface
  case scanFailed
  case getCachedScanResultsFailed
}

class WiFiScanner {
	let client: CWWiFiClient = CWWiFiClient.shared()
    var interface: CWInterface
    let encoder = JSONEncoder();

    init?() throws {
        guard let interface = self.client.interface() else {
            throw ScanError.failedToGetWifiInterface
        }
        self.interface = interface
    }

    func scan (name: String? = nil) throws -> Bool? {
        if (try? self.interface.scanForNetworks(withName: name)) != nil {
            return true
        } else {
            throw ScanError.scanFailed
        }
    }

    func scanV2 (name: String? = nil) throws -> Array<WiFiInfo>? {

        if let networks = try? self.interface.scanForNetworks(withName: name) {
            var infos = [WiFiInfo]()
            for network in networks {
                infos.append( WiFiInfo(network: network))
            }
            return infos
        } else {
            throw ScanError.getCachedScanResultsFailed
        }
    }

    func getCachedScanResults (name: String? = nil) throws -> String? {
        encoder.outputFormatting = .prettyPrinted
        if let networks = self.interface.cachedScanResults() {
            var infos:Array = [WiFiInfo]()
            for network in networks {
                let wifiInfo:WiFiInfo = WiFiInfo(network: network);
                infos.append(wifiInfo)
            }
            return String(decoding: try encoder.encode(infos), as: UTF8.self)
        } else {
            throw ScanError.getCachedScanResultsFailed
        }
    }

}
