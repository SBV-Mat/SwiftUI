//
//  NavigationObject+MotionManager.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  NavigationObject+MotionManager.swift
//  MyWayMockup
//
//  Created by Luciano Butera on 24.01.2024.
//  Copyright © 2024 SBV-FSA. All rights reserved.
//

import Foundation
import CoreMotion

// LB this Motion-Manager-Stuff should be a separated Class to be used in Route-Recording as well
// Maybe in conjunction with Device-Orientation which is in RouteDetailViewController only
// Possibly find better way for Shaking-Detection
extension NavigationObject {
    
    func startMotionManager() {
        motionManager = CMMotionManager();
        if motionManager!.isAccelerometerAvailable {
            motionManager!.accelerometerUpdateInterval = 0.1
            motionManager!.startAccelerometerUpdates()
        } else {
            print("MotionManager is not available")
        }
    }
    
    func stopMotionManager() {
        if let motManStop = self.motionManager {
            if(self.motionManager!.isAccelerometerActive) {
                motManStop.stopAccelerometerUpdates();
            }
        }
    }
    
    // LB: Ist das für die Schüttel-Funktion? Prüfen
    /**
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if isDeviceFlat(){
            userDidShakeDevice(currentLocation: currentLocation)
        }
    }
     */
    
    func isDeviceFlat() -> Bool {
        if let accelerometerData = motionManager?.accelerometerData {
            let y = accelerometerData.acceleration.y
            let z = accelerometerData.acceleration.z
            
            return (z < -0.8 && y > -0.3 && y < 0.3)
        }
        return false
    }
}