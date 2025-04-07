//
//  LocationViewModel.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 26.03.2025.
//

import Foundation
import Combine
import CoreLocation

class LocationViewModel: ObservableObject {
    @Published var currentLocation: CLLocation?

    private var cancellables = Set<AnyCancellable>()

    init() {
        LocationService.shared.$currentLocation
            .assign(to: &$currentLocation)
    }

    func startLocationUpdates() {
        LocationService.shared.startUpdating()
    }
    
    func stopLocationUpdates() {
        LocationService.shared.stopUpdating()
    }
}
