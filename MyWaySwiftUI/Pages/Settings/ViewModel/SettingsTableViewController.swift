//
//  SettingsTableViewController.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//

import UIKit


/// Dazugehörige Klasse zu der Einstellungs-Maske. Darstellung von Elementen, welche angepasst werden können
class SettingsTableViewController: UITableViewController  {
    
    
    //MARK: Declaration-Section
    //User-Default Key-Names für "Karte POIS anzeigen" etc.
    let settingsShowMapCompass = MyWayConstants.UserDefaultConstants.settingsShowMapCompass;
    let settingsShowMapTraffic = MyWayConstants.UserDefaultConstants.settingsShowMapTraffic;
    let settingsMapMode = MyWayConstants.UserDefaultConstants.settingsMapMode;
    let settingsDirectionUnit = MyWayConstants.UserDefaultConstants.settingsDirectionsUnit;
    let settingsVibrateWhenPointAdded = MyWayConstants.UserDefaultConstants.settingsVibrateWhenPointAdded;
    let settingsVibrateSoundNextPoint = MyWayConstants.UserDefaultConstants.settingsVibrateSoundRoutingNextPoint;
    let settingsPlayHinweiston = MyWayConstants.UserDefaultConstants.settingsPlayHinweiston;
    let settingsAddAutoPointInSec =  MyWayConstants.UserDefaultConstants.settingsAddAutoPointInSec;
    let settingsRoutingNearestPoint = MyWayConstants.UserDefaultConstants.settingsRoutingNearestPoint;
    let settingsColorRoutePoint = MyWayConstants.UserDefaultConstants.settingsColorRoutepoint;
    let settingsAnnounceNextPointDistanceInSeconds = MyWayConstants.UserDefaultConstants.settingsAnnounceNextPointDistanceInSeconds;
    let settingsAnnounceNextPointDistanceInMeters = MyWayConstants.UserDefaultConstants.settingsAnnounceNextPointInMeters;
    let settingsDistanceUnit = MyWayConstants.UserDefaultConstants.settingsDistanceUnit;
    let settingsMapPresentationMode = MyWayConstants.UserDefaultConstants.PRESENTATIONMODE;
    let settingsShakeToAddANewPoint = MyWayConstants.UserDefaultConstants.settingsShakeToAddANewPoint;
    let settingsChangeNextPointRouteAlert = MyWayConstants.UserDefaultConstants.settingsChangeAutoNextPointRouteAlert;

}
