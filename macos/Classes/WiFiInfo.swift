import CoreWLAN

struct WiFiInfo: Codable {
    
//    // Do you want my password?
//    var SSID: String
//    // mac address
//    var bssid: String
//    // a, ac, b, g, n
//    var modes: String
//    // 2.4G: 1-14, 5G: TL;DR
//    var channel: String
//    // 2.4, 5GHz
//    var channel_band: String
//    // 20, 40, 80, 160MHz
//    var channel_bandwidth: String
//    // WPA...
//    var AuthAlgorithm: String
//    // dBm
//    var noise: String
//    // dBm
//    var rssi: String
//
//    var ssidData: String?
//
//    init (network: CWNetwork) {
//        self.SSID              = network.ssid ?? ""
//        self.ssidData          = String(decoding: network.ssidData!, as: UTF8.self)
//        self.bssid             = network.bssid ?? ""
//        self.channel           = network.wlanChannel?.channelNumber != nil ? "\(network.wlanChannel?.channelNumber)" : ""
//        self.channel_band      = gen_channel_band(cw_channel_band: network.wlanChannel?.channelBand)
//        self.modes             = gen_modes(network: network)
//        self.channel_bandwidth = gen_channel_bandwidth(cw_channel_width: network.wlanChannel?.channelWidth)
//        self.AuthAlgorithm     = gen_security(network: network)
//        self.noise             = String(network.noiseMeasurement) + " dBm"
//        self.rssi              = String(network.rssiValue) + " dBm"
//    }
    
    var AuthAlgorithm: String?
    var BSSNetworkType: String?
    var Connectable: Bool?
    var DefaultCipherAlgorithm: String?
    var Flags: String?
    var NumberOfBSSID: Int?
    var NumberOfPHYTypesSupported: Int?
    var ProfileName: String?
    var RSSI: Int?
    var SSID: String?
    var BSSID: String?
    var SecurityEnabled: Bool?
    var SignalQuality: Int?

    init(network: CWNetwork) {
        self.AuthAlgorithm = gen_security(network: network)
        self.BSSNetworkType = nil
        self.Connectable = nil
        self.DefaultCipherAlgorithm = nil
        self.Flags = nil
        self.NumberOfBSSID = nil
        self.NumberOfPHYTypesSupported = gen_modes(network: network).components(separatedBy:",").count
        self.ProfileName = nil
        self.RSSI = network.rssiValue
        self.SSID = network.ssid
        self.BSSID = network.bssid
        self.SecurityEnabled = !gen_security(network: network).contains("None")
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

    
    // OMG so much...
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

