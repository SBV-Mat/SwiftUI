//
//  NavigationMode.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  NavigationMode.swift
//  MyWayMockup
//
//  Created by Luciano Butera on 21.12.2023.
//  Copyright © 2023 SBV-FSA. All rights reserved.
//

import Foundation

enum NavigationMode {
    case Forward, Backward, PoiObservation, undefined;
    
    init() {
        self = .undefined
    }
}

