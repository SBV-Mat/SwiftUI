//
//  NavigationObject.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  NavigationObject.swift//  MyWayMockup
//
//  Created by Luciano Butera on 21.12.2023.
//  Copyright © 2023 SBV-FSA. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

/**
 Missing:
 1. Re calculation of Points with POI Observation,
 2. When recalculating and start-Up for POI Observation. select Point in Direction. as next Index. Current Direction is from Clock-10 to Clock-2.
 3. manage the points-Change when Recalculating with POI
 4. Check Performance of recalculating the whole route. Previously only first cells where calculated. now every distance is calculated on every update. Possibly only in POI Navigation and remove proximity-State on Points to calculate it as needed from Table-View.
 5. Add Pause Function to Resume at same Index. for Forward and Backward
 6. Add mechanisme for Round-Routes. Currently if first and last pont 100 m it takes the first in forward and last in Backward. Problem, what if second pointis nearer?
 7. Add mechanism when starting Navigation near to a point not to Auto-Switch.
 8. check what happens after point change, when next Point very near.
 9. How can error be transmitted on Start-Up of Navigation. Read Notifications.Documentation
 10. Define Point-Change and maybe immediat proximity based on Point and GPS Accuracy
 11. Check Performance with big Poi Observation Routes. Can we improve the recalculation
 12. Check that with Navigation in the correct situation Course or Heading is transpitted. Shoulc be done in MWLoc Manager
 13. check how Shaking is working. Is it Motion-Ended in the navigation+Localisation file?
 */

class NavigationObject {
    let navigationMode: NavigationMode
    var routePoints: [Point]
    let settings: NavigationSettings
    var currentIndex = 0
    var currentLocation: CLLocation
    var currentHeading: Double?
    var currentTargetLocation: CLLocation?
    
    // Variable for Dynamic feedback
    //Brauchen wir zur Abspeicherung der ursprünglichen Distanz für Announce vom Drittel des Weges
    private var lastAnnouncedDistance = 0.0 // for Dynamic calculation
    private var lastProximity = PointProximity.undefined
    
    // timer
    weak var navigationHintTimer: Timer?
    var motionManager: CMMotionManager?
    let localizeFastErreicht = NSLocalizedString("fast erreicht", comment: "navi anweisung: fast erreicht");
    let localizeFuer = NSLocalizedString("Für", comment: "Navi Anweisung: Für");
    let localizeDannWeiter = NSLocalizedString("dann weiter für", comment: "Navi Anweisung: dann weiter für");
    
    init?(mode: NavigationMode, points: [Point]?,
          location: CLLocation?, heading: Double? = nil) {
        guard let p = points else {
            NotificationCenter.default.post(name: .navError, object: NavigationError.invalidRoute)
            return nil
        }
        guard let location = location else {
            NotificationCenter.default.post(name: .navError, object: NavigationError.invalidLocation)
            return nil
        }
        guard !p.isEmpty else {
            NotificationCenter.default.post(name: .navError, object: NavigationError.invalidRoute)
            return nil
        }
        
        self.navigationMode = mode
        self.settings = NavigationSettings()
        self.currentLocation = location
        self.currentHeading = heading
        
        // Sorting ascending or descending
        if mode == .Forward || mode == .PoiObservation {
            self.routePoints = p
        } else {
            self.routePoints = p.reversed()
        }
        
        guard startNavigation() else {
            NotificationCenter.default.post(name: .navError, object: nil)
            return nil
        }
        // Start AudioSession
        MyWaySpeechService.sharedInstance.setAudioSession();
        startMotionManager()
    }
    
    func startNavigation() -> Bool {
        var success = true
        
        // setup Rout for Nav-startup
        for p in routePoints {
            //            p.pointPassed = false
            //            p.pointProximity = .undefined
        }
        
        if settings.startNavigationAtNearestPoint || navigationMode == .PoiObservation {
            //            calculateDistance(to: currentLocation)
        }
        
        return success
    }
    
    deinit {
        //LB: Isn't a check needed to see if Poi Watch is activated
        MyWaySpeechService.sharedInstance.deactivateAVAudioSession()
        stopMotionManager()
        navigationHintTimer?.invalidate()
    }
}
