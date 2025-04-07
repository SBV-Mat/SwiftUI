//
//  MainView.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            AddressSearchView()
                .tabItem {
                    Label("Navigation", systemImage: "map")
                }
            
            POITab()
                .tabItem {
                    Label("POI", systemImage: "mappin")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainView()
}
