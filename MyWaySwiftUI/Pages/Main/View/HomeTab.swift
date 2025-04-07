//
//  HomeTab.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationView {
            Text("Home")
                .font(.largeTitle)
                .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeTab()
}
