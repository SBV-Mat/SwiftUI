//
//  POITab.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import SwiftUI

struct POITab: View {
    var body: some View {
        NavigationView {
            Text("Points of interest")
                .font(.largeTitle)
                .navigationTitle("POI")
        }
    }
}

#Preview {
    POITab()
}
