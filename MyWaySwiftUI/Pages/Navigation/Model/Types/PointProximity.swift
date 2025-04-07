//
//  PointProximity.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  PointProximity.swift
//  MyWayMockup
//
//  Created by Luciano Butera on 03.01.2024.
//  Copyright © 2024 SBV-FSA. All rights reserved.
//

import Foundation

enum PointProximity {
    case reached  // Depends on GPS, here 15 m (t switch)/
    case immediat // 27.5 // preparing for switching
    case range // 40.0 Switching range. If is immediate and then leaves range, it is missed
    case close // 60 Stops standard Feedback mode and goes to switching mode
    case far // 150 m
    case undefined
}
