//
//  AddressSearchViewModel.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import Foundation
import Combine
import MapKit

class AddressSearchViewModel: NSObject, ObservableObject {
    @Published var startAddress: String = "" {
        didSet { updateSearchResults(for: startAddress) }
    }
    @Published var destinationAddress: String = "" {
        didSet { updateSearchResults(for: destinationAddress) }
    }
    
    @Published var searchResults: [(String, String)] = []
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    // Fetch user location from LocationService
    func useCurrentLocationAsStart() {
        if let userLocation = LocationService.shared.currentLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { [weak self] placemarks, error in
                if let address = placemarks?.first?.name {
                    DispatchQueue.main.async {
                        self?.startAddress = address
                    }
                }
            }
        }
    }
    
    // Update search results when user types
    private func updateSearchResults(for query: String) {
        if query.isEmpty {
            searchResults = []
        } else {
            searchCompleter.queryFragment = query
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension AddressSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results.map { ($0.title, $0.subtitle) }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching address suggestions: \(error.localizedDescription)")
    }
}
