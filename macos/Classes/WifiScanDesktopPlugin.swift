import Cocoa
import FlutterMacOS
import CoreWLAN
import CoreLocation

// Main Plugin Class
public class WifiScanDesktopPlugin: NSObject, FlutterPlugin {
    
    private var scanHandler: WifiScanStreamHandler
    
    init(scanHandler: WifiScanStreamHandler) {
        self.scanHandler = scanHandler
        super.init()
    }

    // Event and Method Channels are registered here
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "get_available_networks", binaryMessenger: registrar.messenger)
        let eventChannel = FlutterEventChannel(name: "scan_callback", binaryMessenger: registrar.messenger)
        let scanHandler = WifiScanStreamHandler()
        let instance = WifiScanDesktopPlugin(scanHandler: scanHandler)
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(scanHandler)
    }

    // Flutter method call
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let scanner = try? WiFiScanner()
        switch call.method {
        case "getAvailableNetworks":
            do{
                result(try scanner?.getCachedScanResults())
            }catch let error{
                result(error.localizedDescription);
            }
            
        case "scan":
            do{
                let scanStatus = try scanner?.scan()
                scanHandler.eventSink?(scanStatus)
            }catch let error{
                result(error.localizedDescription)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// Stream handler for scan callback
class WifiScanStreamHandler: NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink event: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = event
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

}

// Error descriptor
enum ScanError: Error {
    case failedToGetWifiInterface
    case scanFailed
    case getCachedScanResultsFailed
}

// WifiScanner Class
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

    // Calling this will perform a new scan
    func scan (name: String? = nil) throws -> Bool? {
        if (try? self.interface.scanForNetworks(withName: name)) != nil {
            return true
        } else {
            throw ScanError.scanFailed
        }
    }

    // Calling this will scan and return the available networks
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

    // Returns Cached scan results, can be called without performing scan
    func getCachedScanResults (name: String? = nil) throws -> String? {
        encoder.outputFormatting = .prettyPrinted
        do{
            let networks = self.interface.cachedScanResults()
            if networks != nil{
                var infos:Array = [WiFiInfo]()
                for network in networks! {
                    let wifiInfo:WiFiInfo = WiFiInfo(network: network);
                    infos.append(wifiInfo)
                }
                return String(decoding: try encoder.encode(infos), as: UTF8.self)
            }
            return "cachedScanResults returned nil"
        }catch let error{
            throw error
        }
        
    }
    
}

// Model to store the Wifi Infos
struct WiFiInfo: Codable {

    var AuthAlgorithm: String?
    var BSSNetworkType: String?
    var Connectable: String?
    var DefaultCipherAlgorithm: String?
    var Flags: String?
    var NumberOfBSSID: String?
    var NumberOfPHYTypesSupported: String?
    var ProfileName: String?
    var RSSI: String?
    var SSID: String?
    var BSSID: String?
    var SecurityEnabled: String?
    var SignalQuality: String?
    
    init(network: CWNetwork) {
        self.AuthAlgorithm = gen_security(network: network)
        self.BSSNetworkType = nil
        self.Connectable = nil
        self.DefaultCipherAlgorithm = nil
        self.Flags = nil
        self.NumberOfBSSID = nil
        self.NumberOfPHYTypesSupported = String(gen_modes(network: network).components(separatedBy:",").count)
        self.ProfileName = nil
        self.RSSI = String(network.rssiValue)
        self.SSID = network.ssid
        self.BSSID = network.bssid
        self.SecurityEnabled = (gen_security(network: network).contains("None")==true) ? "No" : "Yes"
        self.SignalQuality = nil
    }
    
    
}


func gen_channel_bandwidth (cw_channel_width: CWChannelWidth?) -> String {
    if cw_channel_width == CWChannelWidth.width20MHz {
        return "20MHz"
    } else if cw_channel_width == CWChannelWidth.width40MHz {
        return "40MHz"
    } else if cw_channel_width == CWChannelWidth.width80MHz {
        return "80MHz"
    } else if cw_channel_width == CWChannelWidth.width160MHz {
        return "160MHz"
    } else {
        return ""
    }
}

func gen_modes (network: CWNetwork) -> String {
    var res = ""
    
    if network.supportsPHYMode(CWPHYMode.modeNone) {
        res += "None,"
    }
    if network.supportsPHYMode(CWPHYMode.mode11a) {
        res += "a,"
    }
    if network.supportsPHYMode(CWPHYMode.mode11ac) {
        res += "ac,"
    }
    if network.supportsPHYMode(CWPHYMode.mode11b) {
        res += "b,"
    }
    if network.supportsPHYMode(CWPHYMode.mode11g) {
        res += "g,"
    }
    if network.supportsPHYMode(CWPHYMode.mode11n) {
        res += "n,"
    }
    
    return res
}

func gen_channel_band (cw_channel_band: CWChannelBand?) -> String {
    if cw_channel_band == CWChannelBand.band2GHz {
        return "2.4GHz"
    } else if cw_channel_band == CWChannelBand.band5GHz {
        return "5GHz"
    } else {
        return ""
    }
}

func gen_security (network: CWNetwork) -> String {
    var res = ""

    if network.supportsSecurity(CWSecurity.none) {
        res += "None/"
    }
    if network.supportsSecurity(CWSecurity.unknown) {
        res += "Unknown/"
    }
    if network.supportsSecurity(CWSecurity.dynamicWEP) {
        res += "Dynamic WEP/"
    }
    if network.supportsSecurity(CWSecurity.enterprise) {
        res += "Enterprise/"
    }
    if network.supportsSecurity(CWSecurity.personal) {
        res += "Personal/"
    }
    if network.supportsSecurity(CWSecurity.WEP) {
        res += "WEP/"
    }
    if network.supportsSecurity(CWSecurity.wpa2Enterprise) {
        res += "WPA2 Enterprise/"
    }
    if network.supportsSecurity(CWSecurity.wpa2Personal) {
        res += "WPA2 Personal/"
    }
    if network.supportsSecurity(CWSecurity.wpaEnterprise) {
        res += "WPA Enterprise/"
    }
    if network.supportsSecurity(CWSecurity.wpaEnterpriseMixed) {
        res += "WPA Enterprise Mixed/"
    }
    if network.supportsSecurity(CWSecurity.wpaPersonal) {
        res += "WPA Personal/"
    }
    if network.supportsSecurity(CWSecurity.wpaPersonalMixed) {
        res += "WPA Personal Mixed/"
    }
    
    return res
}


