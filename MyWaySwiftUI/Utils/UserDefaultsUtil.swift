//
//  UserDefaultsUtil.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  UserDefaultsUtil.swift
//  MyWayMockup
//
//  Created by Erkan Kuzucular on 16.08.19.
//  Copyright © 2019 SBV-FSA. All rights reserved.
//

import Foundation




struct UserDefaultsUtil {
    static var settingsSecondsForAnnouncingNextPoint: Double = 30.0;
    static var settingsMetersForAnnouncingNextPoint:Double = 500.0;
    static var settingsAnnouncingInMeters: Bool = false;
    static var settingsMaxPOIDistance: Int = 1
    static var settingsReadAddressInBackground = false
    static var settingsSelectedPOICategories: String = "";
    static var addAutoPointInSeconds: Int = 9999;
    static var deviceShouldVibrateWhenPointWasAdded: Bool = false
    
    //Hier alle User-Default-Settings aufnehmen
    static func setUserDefaultForKey(booleanForKey:Bool, keyName:String) {
        UserDefaults.standard.set(booleanForKey, forKey: keyName);
    }
    
    static func setUserDefaultForStringValue(value:String, keyName:String) {
        UserDefaults.standard.set(value, forKey: keyName);
    }
    
    static func setUserDefaultForDoubleValue(value:Double, keyName: String) {
        UserDefaults.standard.set(value, forKey: keyName);
    }
    
    static func setUserDefaultForIntValue(value:Int, keyName: String) {
        UserDefaults.standard.set(value, forKey: keyName);
    }
    
    static func getUserDefaultForKey(keyName:String) -> Bool {
        return UserDefaults.standard.bool(forKey: keyName);
    }
    
    static func getUserDefaultForKeyString(keyName:String) -> String {
        var value = "";
        
        if let userDef = UserDefaults.standard.string(forKey: keyName) {
            value = userDef;
        }
        return value;
    }
    
    static func getUserDefaultForKeyDouble(keyName:String) -> Double {
        return UserDefaults.standard.double(forKey: keyName)
    }
    
    static func getUserDefaultForKeyInt(keyName:String) -> Int {
        return UserDefaults.standard.integer(forKey: keyName)
    }

    static func getIntervalForAddingAutoPoints() -> Int {
        return self.addAutoPointInSeconds;
    }
    
    
    static func checkIfDeviceShouldVibrateWhenPointWasAdded() {
        let settingsVibrateWhenPointAdded = "settingsVibrateWhenPointAdded";
        self.deviceShouldVibrateWhenPointWasAdded =
            UserDefaultsUtil.getUserDefaultForKey(keyName: settingsVibrateWhenPointAdded);
    }
    
//    static func checkIfDeviceShouldVibrateAndSoundForNextPoint() {
//        
//        
//        
//    }
    
    static func vibrateDeviceWhenPointWasAdded() -> Bool {
        return self.deviceShouldVibrateWhenPointWasAdded;
    }
    
    static func checkIfUserDefaultsWereSet() {
        let settingsVibrateWhenPointAdded = "settingsVibrateWhenPointAdded";
        
        if(getUserDefaultForKeyString(keyName: settingsVibrateWhenPointAdded) == "") {
            //Die User-Default-Werte wurden nocht nicht gesetzt, daher setzen.
            //IM Normalfall beim ersten Mal Starten der App oder wenn die APp gelöscht wurde
            setUserDefaultsForAllKeysToDefault();
        }
    }
    
    static func setSecondsForAddingAutoPoints() {
        let settingsAddAutoPointInSec = "settingsAddAutoPointInSec";
        
        UserDefaultsUtil.addAutoPointInSeconds = Int(UserDefaultsUtil.getUserDefaultForKeyString(keyName: settingsAddAutoPointInSec))!;
    }
    
    
    static func setSecondsForAnnouncingNextPoint() {
        let settingsAnnounceNextPointDistanceInSeconds = "settingsAnnounceNextPointDistanceInSeconds";
        UserDefaultsUtil.settingsSecondsForAnnouncingNextPoint = UserDefaultsUtil.getUserDefaultForKeyDouble(keyName: settingsAnnounceNextPointDistanceInSeconds);
        
        let settingsAnnounceNextPointInMeters = "settingsAnnounceNextPointDistanceInMeters";
        UserDefaultsUtil.settingsAnnouncingInMeters = UserDefaultsUtil.getUserDefaultForKey(keyName: settingsAnnounceNextPointInMeters);
    }
    
    static func getSecondsForAnnouncingNextPoint() -> Double {
        return self.settingsSecondsForAnnouncingNextPoint;
    }
    
    static func getAnnounceInMetersNextPoint() -> Bool {
        return self.settingsAnnouncingInMeters;
    }
    
    static func setUserDefaultsForAllKeysToDefault() {
        
        let settingsHinweiston = MyWayConstants.UserDefaultConstants.settingsPlayHinweiston;
        let settingsShowMapCompass = MyWayConstants.UserDefaultConstants.settingsShowMapCompass;
        let settingsShowMapTraffic = MyWayConstants.UserDefaultConstants.settingsShowMapTraffic;
        let settingsMapMode = MyWayConstants.UserDefaultConstants.settingsMapMode;
        let settingsVibrateWhenPointAdded = MyWayConstants.UserDefaultConstants.settingsVibrateWhenPointAdded;
        let settingsAddAutoPointInSec = MyWayConstants.UserDefaultConstants.settingsAddAutoPointInSec;
        let settingsHomeAdress = MyWayConstants.UserDefaultConstants.settingsHomeAdress;
        let settingsHomeAdressLattitude = MyWayConstants.UserDefaultConstants.settingsHomeAdressLattitude;
        let settingsHomeAdressLongitude = MyWayConstants.UserDefaultConstants.settingsHomeAdressLongitude;
        let settingsAnnounceNextPointDistanceInSeconds = MyWayConstants.UserDefaultConstants.settingsAnnounceNextPointDistanceInSeconds;
        let settingsAnnounceNextPointInMeters = MyWayConstants.UserDefaultConstants.settingsAnnounceNextPointInMeters;
        let settingsAnnounceAutomaticOutput = MyWayConstants.UserDefaultConstants.settingsAnnounceAutomaticOutput;
        let settingsAnnounceAutomaticDirectionOutput = MyWayConstants.UserDefaultConstants.settingsAnnounceAutomaticDirectionOutput;
        let settingsRoutingNearestPoint = MyWayConstants.UserDefaultConstants.settingsRoutingNearestPoint;
        let settingsDistanceUnit = MyWayConstants.UserDefaultConstants.settingsDistanceUnit;
        let settingsDirectionsUnit = MyWayConstants.UserDefaultConstants.settingsDirectionsUnit;
        let settingsMaxPoiDistance = MyWayConstants.UserDefaultConstants.settingsMaxPOIDistance
        let settingsReadAddressInBackground = MyWayConstants.UserDefaultConstants.settingsReadAddressInBackground
        let settingsSelectedPOICategories = MyWayConstants.UserDefaultConstants.settingsSelectedPOICategories
        let settingsMapPresentationMode = MyWayConstants.UserDefaultConstants.PRESENTATIONMODE;
        let settingsShakeToAddANewPoint = MyWayConstants.UserDefaultConstants.settingsShakeToAddANewPoint;
        let settingsChangeNextPointRouteAlert = MyWayConstants.UserDefaultConstants.settingsChangeAutoNextPointRouteAlert;
        let settingsSavedSortRouteRoutine = MyWayConstants.UserDefaultConstants.settingsSavedRouteSortRoutine;
        let settingsColorRoutepoint = MyWayConstants.UserDefaultConstants.settingsColorRoutepoint;
        
        let settingsVibraSoundRoutingNextPoint = MyWayConstants.UserDefaultConstants.settingsVibrateSoundRoutingNextPoint;
        
        setUserDefaultForKey(booleanForKey: true, keyName: settingsShowMapCompass);
        setUserDefaultForKey(booleanForKey: false, keyName: settingsShowMapTraffic);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsVibrateWhenPointAdded);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsVibraSoundRoutingNextPoint);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsShakeToAddANewPoint);
        setUserDefaultForStringValue(value: "9999", keyName: settingsAddAutoPointInSec)
        setUserDefaultForStringValue(value: NSLocalizedString("Keine Adresse definiert", comment: "Take Me Home Default Value"), keyName: settingsHomeAdress);
        setUserDefaultForDoubleValue(value: 0.0, keyName: settingsHomeAdressLattitude);
        setUserDefaultForDoubleValue(value: 0.0, keyName: settingsHomeAdressLongitude);
        setUserDefaultForDoubleValue(value: 30.0, keyName: settingsAnnounceNextPointDistanceInSeconds);
        setUserDefaultForIntValue(value: 2, keyName: settingsSavedSortRouteRoutine);
        setUserDefaultForKey(booleanForKey: false, keyName: settingsAnnounceNextPointInMeters);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsAnnounceAutomaticOutput);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsAnnounceAutomaticDirectionOutput);
        setUserDefaultForKey(booleanForKey: false, keyName: settingsHinweiston);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsRoutingNearestPoint);
        setUserDefaultForKey(booleanForKey: true, keyName: settingsColorRoutepoint)
        setUserDefaultForStringValue(value: MyWayConstants.DistanceDirectionConstants.CLOCKWISE, keyName: settingsDirectionsUnit);
        setUserDefaultForStringValue(value: MyWayConstants.MapType.STANDARD, keyName: settingsMapMode);
        setUserDefaultForStringValue(value: MyWayConstants.DistanceUnitConstants.DISTANCE_UNIT_IN_METERS, keyName: settingsDistanceUnit);
        setUserDefaultForIntValue(value: 200, keyName: settingsMaxPoiDistance);
        setUserDefaultForKey(booleanForKey: false, keyName: settingsReadAddressInBackground)
        setUserDefaultForStringValue(value: PresentationType.textMode.rawValue, keyName: settingsMapPresentationMode);
        setUserDefaultForStringValue(value: "", keyName: settingsSelectedPOICategories);
        
        setUserDefaultForStringValue(value: MyWayConstants.AutoPointChangeConstants.AUTO_POINT_CHANGE_CHANGE_NXT_POINT, keyName: settingsChangeNextPointRouteAlert);
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

