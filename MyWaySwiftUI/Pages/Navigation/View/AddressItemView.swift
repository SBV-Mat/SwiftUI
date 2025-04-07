//
//  AddressItemView.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 26.03.2025.
//


import SwiftUI

struct AddressItemView: View {
    let address: String
    let onSelect: () -> Void

    var body: some View {
        Text(address)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .onTapGesture {
                onSelect()
            }
    }
}