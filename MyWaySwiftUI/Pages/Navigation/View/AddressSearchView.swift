//
//  AddressSearchView.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import SwiftUI
import CoreLocation

struct AddressSearchView: View {
    @StateObject private var addressSearchVM = AddressSearchViewModel()
    
    @State private var activeField: ActiveField? = nil // Track which field is active
    enum ActiveField {
        case start, destination
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("From: \(addressSearchVM.startAddress)")
                        .foregroundColor(.secondary)
                    TextField("Start Address", text: $addressSearchVM.startAddress)
                        .font(.system(size: 25))
                        .padding()
                        .frame(height: 60)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2))
                        .padding([.leading, .trailing, .bottom], 15)
                        .onTapGesture {
                            handleStartFieldTap()
                        }
                }
                
                HStack {
                    Text("To: \(addressSearchVM.destinationAddress)")
                        .foregroundColor(.secondary)
                    TextField("Destination Address", text: $addressSearchVM.destinationAddress)
                        .font(.system(size: 25))
                        .padding()
                        .frame(height: 60)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2))
                        .padding([.leading, .trailing, .bottom], 15)
                        .onTapGesture {
                            handleDestinationFieldTap()
                        }
                }
                
                if activeField != nil {
                    Text("Enter \(activeField == .start ? "start" : "destination") address...")
                }
                                
                if !addressSearchVM.searchResults.isEmpty {
                    List(addressSearchVM.searchResults.indices, id: \.self) { index in
                        
                        let result = "\(addressSearchVM.searchResults[index].0), \(addressSearchVM.searchResults[index].1)"
                        
                        AddressItemView(address: result) {
                            if activeField == .start {
                                addressSearchVM.startAddress = result
                            } else if activeField == .destination {
                                addressSearchVM.destinationAddress = result
                            }
                        }
                    }
                    .frame(height: 150)
                } else {
                    Spacer()
                }
                
                Button("Find Route") {
                    print("Start navigation")
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .padding()
                .background(.thinMaterial)
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
            .navigationTitle("Navigation")
            .padding(.top)
        }
    }
    
    private func handleStartFieldTap(){
        print("Voiceover is running: \(UIAccessibility.isVoiceOverRunning)")
        activeField = .start
    }
    
    private func handleDestinationFieldTap(){
        print("Voiceover is running: \(UIAccessibility.isVoiceOverRunning)")
        activeField = .destination
    }
}

#Preview {
    AddressSearchView()
}
