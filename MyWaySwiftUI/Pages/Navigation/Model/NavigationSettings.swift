//
//  NavigationSettings.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  NavigationSettings.swift
//  MyWayMockup
//
//  Created by Luciano Butera on 21.12.2023.
//  Copyright © 2023 SBV-FSA. All rights reserved.
//

import Foundation

class NavigationSettings {
    
    // Point Switching
    var switchAutoToNextPoint = false
    var alertNextPointWasNotReached = false
    
    // Navigation Starting
    var startNavigationAtNearestPoint = false
    var announceNextPoint = true
    var announceDirectionOfNextPoint = true
    
    // Feedback
    var soundAndVibrate = true
    var navFeedbackMode: NavigationFeedbackMode = .none
    var dynamicFeedback = 0.0
    var staticFeedback = 0.0
    
    let settingsAnnounceAutomaticOutput = MyWayConstants.UserDefaultConstants.settingsAnnounceAutomaticOutput
    let settingsPlayHinweiston = MyWayConstants.UserDefaultConstants.settingsPlayHinweiston;
    let settingsAnnounceAutomaticDirectionOutput = MyWayConstants.UserDefaultConstants.settingsAnnounceAutomaticDirectionOutput;
    let settingsRoutingNearestPoint = MyWayConstants.UserDefaultConstants.settingsRoutingNearestPoint;
    
    init() {
        soundAndVibrate = UserDefaultsUtil.getUserDefaultForKey(keyName: MyWayConstants.UserDefaultConstants.settingsVibrateSoundRoutingNextPoint);
        
        switch UserDefaultsUtil.getUserDefaultForKeyString(keyName: MyWayConstants.UserDefaultConstants.settingsChangeAutoNextPointRouteAlert) {
            
            //Damit, falls es Nutzer gab welche vor der Umstellung Meldung angezeigt haben MyWay sich gleich verhält wie wenn Automatisch zum nächsten Punkt wechsel
        case MyWayConstants.AutoPointChangeConstants.AUTO_POINT_CHANGE_SHOW_ALERT:
            alertNextPointWasNotReached = true
            switchAutoToNextPoint = true
        case MyWayConstants.AutoPointChangeConstants.AUTO_POINT_CHANGE_CHANGE_NXT_POINT:
            alertNextPointWasNotReached = false
            switchAutoToNextPoint = true
        case MyWayConstants.AutoPointChangeConstants.AUTO_POINT_CHANGE_CHANGE_DO_NOTHING:
            alertNextPointWasNotReached = false;
            switchAutoToNextPoint = false;
        default:
            alertNextPointWasNotReached = false;
            switchAutoToNextPoint = false;
        }
        announceNextPoint = UserDefaultsUtil.getUserDefaultForKey(keyName: settingsAnnounceAutomaticOutput)
        
        announceDirectionOfNextPoint = UserDefaultsUtil.getUserDefaultForKey(keyName: settingsAnnounceAutomaticDirectionOutput);
        
        startNavigationAtNearestPoint = UserDefaultsUtil.getUserDefaultForKey(keyName: settingsRoutingNearestPoint);
        
        //LB: Add more options like none, 1/2 and 1/4
        //LB: Change settings to meaning-Full data (Not 999
        //Falls hier die Zeit auf 9999 eingestellt, dann alle 15 Sekunden Check ob ein Drittel zurückgelegt
        let announceInSeconds = UserDefaultsUtil.getSecondsForAnnouncingNextPoint();
        
        if announceInSeconds == 9999.0 {
            navFeedbackMode = .dynamicInterval
            staticFeedback = 0.0
            dynamicFeedback = 1 / 3
        } else {
            navFeedbackMode = .staticInterval
            staticFeedback = announceInSeconds
            dynamicFeedback = 0.0
        }
    }
}
