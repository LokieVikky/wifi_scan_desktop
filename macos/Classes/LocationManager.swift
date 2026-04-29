//
//  LocationManager.swift
//  Pods
//
//  Created by Lokesh N on 11/10/25.
//


import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completionHandler: ((String) -> Void)?
    private var hasCalledCompletion = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestAuthorization(completion: @escaping (String) -> Void) {
        self.completionHandler = completion
        self.hasCalledCompletion = false
        
        let currentStatus = getCurrentStatus()
        
        // If already determined, return the status immediately
        if currentStatus != .notDetermined {
            let result = authorizationStatusToString(currentStatus)
            callCompletionOnce(result)
            return
        }
        
        // Request permission and activate location updates
        // This is necessary on macOS for the prompt to appear
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    private func callCompletionOnce(_ result: String) {
        guard !hasCalledCompletion, let handler = completionHandler else {
            return
        }
        
        hasCalledCompletion = true
        handler(result)
        completionHandler = nil
        manager.stopUpdatingLocation()
    }
    
    private func getCurrentStatus() -> CLAuthorizationStatus {
        if #available(macOS 11.0, *) {
            return manager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    // Method for macOS 11+
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = getCurrentStatus()
        if status != .notDetermined {
            let result = authorizationStatusToString(status)
            callCompletionOnce(result)
        }
    }
    
    // Method for earlier macOS versions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            let result = authorizationStatusToString(status)
            callCompletionOnce(result)
        }
    }
    
    private func authorizationStatusToString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return "granted"
        case .denied, .restricted:
            return "denied"
        case .notDetermined:
            return "notDetermined"
        @unknown default:
            return "unknown"
        }
    }
}
