//
//  LocationService.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 26.03.2025.
//

import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService() // Singleton instance

    private var locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    
    private override init() { // Private initializer for singleton
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last // Update latest location
    }
}
