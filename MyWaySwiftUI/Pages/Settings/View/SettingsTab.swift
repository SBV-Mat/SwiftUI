//
//  SettingsTab.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import SwiftUI

struct SettingsTab: View {
    var body: some View {
        NavigationView {
            Text("Settings")
                .font(.largeTitle)
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTab()
}
