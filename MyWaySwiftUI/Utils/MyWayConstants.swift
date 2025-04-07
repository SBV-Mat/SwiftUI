//
//  MyWayConstants.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  MyWayConstants.swift
//  MyWayMockup
//
//  Created by Erkan Kuzucular on 05.04.18.
//  Copyright © 2018 SBV-FSA. All rights reserved.
//

import Foundation


/// Klasse mit Konstanten, welche im ganzen Projekt verwendet werden. Warum eine Struktur? Eignet sich gut, da Werttypen zur Variablenverwaltung übergeben können (und keine Referenztyp). Diese können auch nicht vererbt werden.
struct MyWayConstants {
    
    /// Diese sind sortiert nach deren Typ
    //Localizations
    let localizedAutoPointChange = NSLocalizedString("Automatisch zum nächsten Punkt wechseln", comment: "Automatisch zum nächsten Punkt wechseln. Auswahl Punkt nicht getroffen");
    
    //Distance-Unit Localization
    static let localizedMeter = NSLocalizedString("Meter", comment: "DistanceUnitConstants. Meter.");
    static let localizedFeet = NSLocalizedString("Fuss", comment: "DistanceUnitConstants. Fuss.");
    static let localizedYard = NSLocalizedString("Yard", comment: "DistanceUnitConstants. Yard.");
    
    //Map-Type Localization
    static let localizedStandard = NSLocalizedString("Standard", comment: "Standard. Auswahl Constants.MapType");
    static let localizedHybrid = NSLocalizedString("Hybrid", comment: "Hybrid. Auswahl Constants.MapType");
    static let localizedSatellite = NSLocalizedString("Satellit", comment: "Satellit. Auswahl Constants.MapType");
    
    //Direction-Unit Localization
    static let localizeNordEastCompass = NSLocalizedString("Norden / Osten", comment: "Norden / Osten. Auswahl DistanceDirectionConstants");
    static let localizeClockwise = NSLocalizedString("1 - 12 Uhr", comment: "1 - 12 Uhr. Auswahl DistanceDirectionConstants");
    static let localizeDegree = NSLocalizedString("Grad (Kompass)", comment: "Grad. Auswahl DistanceDirectionConstants");
    static let localizeDegreeVariation = NSLocalizedString("Grad (Ausrichtung)", comment: "Grad Abweichung. Auswahl DistanceDirectionConstants");
    static let localizeOff = NSLocalizedString("Aus", comment: "Aus. Auswahl DistanceDirectionConstants");
    
    //Auto-Point-Change Localization
    static let localizeAutoPointChangeShowAlert = NSLocalizedString("Anzeige Meldung", comment: "Anzeige Meldung. Auswahl AutoPointChangeConstants");
    static let localizeAutoPointChangeNxtPoint = NSLocalizedString("Automatisch zum nächsten Punkt wechseln", comment: "Automatisch zum nächsten Punkt wechseln. Auswahl AutoPointChangeConstants");
    static let localizeAutoPointChangeDoNothing = NSLocalizedString("Nichts unternehmen", comment: "Nichts unternehmen. Auswahl AutoPointChangeConstants");
    
    /// Die gespeicherten Einstellungen für die User-Defaults
    struct UserDefaultConstants {
        static let settingsPlayHinweiston = "settingsPlayHinweiston";
        static let settingsShowMapCompass = "settingsShowMapCompass";
        static let settingsShowMapTraffic = "settingsShowMapTraffic";
        static let settingsMapMode = "settingsMapMode";
        static let settingsVibrateWhenPointAdded = "settingsVibrateWhenPointAdded";
        static let settingsVibrateSoundRoutingNextPoint = "settingsVibrateSoundNextPoint";
        static let settingsAddAutoPointInSec = "settingsAddAutoPointInSec";
        static let settingsHomeAdress = "settingsHomeAdress";
        static let settingsHomeAdressLattitude = "settingsHomeAdressLattitude";
        static let settingsHomeAdressLongitude = "settingsHomeAdressLongitude";
        static let settingsAnnounceNextPointDistanceInSeconds = "settingsAnnounceNextPointDistanceInSeconds";
        static let settingsAnnounceNextPointInMeters = "settingsAnnounceNextPointDistanceInMeters";
        static let settingsAnnounceAutomaticOutput = "settingsAnnounceAutomaticOutput";
        static let settingsAnnounceAutomaticDirectionOutput = "settingsAnnounceAutomaticDirectionOutput";
        static let settingsRoutingNearestPoint = "settingsRoutingNearestPoint";
        static let settingsColorRoutepoint = "settingsColorRoutepoint";
        static let settingsDirectionsUnit = "settingsDirectionsUnit";
        static let settingsDistanceUnit = "settingsDistanceUnit";
        static let settingsShakeToAddANewPoint = "settingsShakeToAddANewPoint";
        static let settingsChangeAutoNextPointRouteAlert = "settingsChangeAutoNextPointRouteAlert";
        static let settingsSavedRouteSortRoutine = "settingsSavedRouteSortRoutine";
        
        // Constants for POI
        static let PRESENTATIONMODE = "presentation_mode"
        static let settingsMaxPOIDistance = "settingsMaxPoiDistance";
        static let settingsSelectedPOICategories = "settingsSelectedPoiCategories";
        static let settingsReadAddressInBackground = "settingsReadAddressInBackground"
    }
    
    /// Lautstärke und andere Einstellungen für die Ausgabe der Sprachausgabe
    /// Entspricht der Default-Geschwindigkeit von Voice-Over
    struct AVSpeechConstants {
        static let AVSpeechVolume: Float = 0.78;
        static let AVSpeechPitch: Float = 1.0;
        static let AVSpeechRate: Float = 0.65;
    }
    
    /// Entfernung der Punkte der Distanz in Metern
    struct RouteConstants {
        /// Die Nähe in Metern ist nicht bekannt
        static let MIN_DISTANCE_PROXIMITY_UNKNOWN = 0.0
        
        /// Die Nähe beträgt 10 Meter (Fast Erreicht). Aber für Routenpunkte, welche bei der Aufnahme gute Signalstärke hatten
        static let MIN_DISTANCE_PROXIMITY_REACHED_FOR_GOOD_LOC_ACCURACY = 10.0;
        
        /// Die Nähe beträgt 15 Meter (Also fast erreicht)
        static let MIN_DISTANCE_PROXIMITY_REACHED = 15.0;
        
        /// Die Nähe beträgt circa 27.5 Meter: Ziel in unmittelbarer Nähe
        static let MIN_DISTANCE_PROXIMITY_IMMEDIATE = 27.5;
        
        /// Die Nähe beträgt circa 40 Meter: Ziel ist nahe
        static let MIN_DISTANCE_PROXIMITY_range = 40.0;
        
        /// Die Nähe beträgt circa 60 Meter: Ziel ist nahe
        static let MIN_DISTANCE_PROXIMITY_NEAR = 60.0;
        
        /// Die Nähe beträgt mehr als 150 Meter: Ziel ist fern
        static let MIN_DISTANCE_PROXIMITY_FAR_AWAY = 150.0;
        
        /// Die Nähe, welche wir bestimmen ob ein Punkt erreicht wurde. 15 Meter muss mindestens überwunden werden, damit ein Punkt als erreicht gekennzeichnet werden kann
        static let DISTANCE_POINT_WAS_REACHED = 15.0;
        
        /// Diese Distanz muss mindestens zurückgelegt werden bevor ein Punkt bei der Aufnahme einer Route abgespeichert werden soll.
        static let MINIMUM_DISTANCE_PASSED_TO_SAVE_AUTO_POINT = 200;
    }
    
    /// Distanzeinheit für die Entfernung der Routenpunkte
    struct DistanceUnitConstants {
        static let DISTANCE_UNIT_IN_METERS = "Meter";
        static let DISTANCE_UNIT_IN_FEET = "Fuss";
        static let DISTANCE_UNIT_IN_YARD = "Yard";
    }
    
    /// Was soll passieren wenn MyWay einen Punkt nicht trifft?
    struct AutoPointChangeConstants {
        static let AUTO_POINT_CHANGE_SHOW_ALERT = "Anzeige Meldung";
        static let AUTO_POINT_CHANGE_CHANGE_NXT_POINT = "Automatisch zum nächsten Punkt wechseln";
        static let AUTO_POINT_CHANGE_CHANGE_DO_NOTHING = "Nichts unternehmen";
    }
    
    /// Wie soll die Richtungsangabe erfolgen. Nach Norden? Oder Uhrzeit?
    struct DistanceDirectionConstants {
        static let NORD_EAST_COMPASS = "Norden / Osten";
        static let CLOCKWISE = "1 - 12 Uhr";
        static let DEGREE = "Grad";
        static let DEGREE_VARIATION = "Grad Variation";
        static let OFF = "Aus";
    }
    
    /// In welchem Intervall sollen Punkte automatisch aufgenommen werden?
    struct SecondsAutoPointAddIntervall {
        static let FIFTEEN = "15";
        static let TWENTY = "20";
        static let TWENTY_FIVE = "25";
        static let THIRTY = "30";
        static let SIGNIFICANT_DIRECTION_CHANGE = NSLocalizedString("Signifikante Richtungsänderung (SR)", comment: "Signifikante Richtungsänderung (SR). Auswahl SecondsAutoPointAddIntervall");
    }
    
    /// Richtwerte (Quelle Internet) für die Wertigkeit der Signalstaerke
    /// 1. <0: Kein Signal
    /// 2. >163: Schwaches Signal
    /// 3. 48 - 163: Durchschnittssignal
    /// 4. 0-47: Gutes Signal
    /// 5. Im Durchschnitt in die Genauigkeit draussen bei gutem Empfang zwischen 5 - 10
    /// 6. Indoor liegt der Wert bei > 50
    struct LocationConstants {
        
        /// kmh for direction calculation (Unter anderem bei der Berechnung der aktuellen Gehgeschwindigkeit benötigt)
        static let MINIMUM_SPEED_FOR_COURSE = 1.8
        
        //// Horizontal-Accuracy der Location hat ein gutes Signal: Besser als 12.5
        static let DESIRED_LOCATION_ACCURACY_GOOD = 12.5;
        
        /// Horizontal-Accuracy der Location hat ein Durchschnittssignal: Schlechter als 48, aber besser als 163
        static let DESIRED_LOCATION_ACCURACY_AVERAGE = 48.0; //
        
        /// Horizontal-Accuracy der Location hat ein schwaches Signal: Schlechter als 163
        static let DESIRED_LOCATION_ACCURACY_BAD = 163.0;
        
        /// Horizontal-Accuracy der Location in einem Gebäude: 50
        static let DESIRED_LOCATION_ACCURACY_IN_A_BUILDING = 50;
        
        /// Die Stärke des Compasses muss mindestens einen Wert erfüllen
        static let MIN_ACCURRACY_OF_COMPASS = 30.0;
    }
    
    /// Die von MyWay unterstuetzten Map-Types
    struct MapType {
        static let STANDARD:String = "Standard";
        static let HYBRID: String = "Hybrid";
        static let SATELLITE: String = "Satellit";
    }
    
    struct DeviceHeading {
        static let NORTH = "Norden";
        static let NORTHEAST = "Nordosten";
        static let EAST = "Osten";
        static let SOUTHEAST = "Südosten";
        static let SOUTH = "Süden";
        static let SOUTHWEST = "Südwesten";
        static let WEST = "Westen";
        static let NORTHWEST = "Nordwesten";
    }
    
    struct FTPConnectionConstants {
        
        /// Minimum Filegrösse für ein FTP-File und das AUfpoppen eines Alert mit der Frage ob der User das File wirklich herunterladen will, da es grösser als 5 Megabyte ist und viele Punkte aufweist
        static let MIN_FILE_SIZE_FOR_FTP_FILE_TO_ALERT_USER = 5.0;
    }
    
    /// Wie heisst unsere Tabelle in CloudKit?
    struct CloudKitConstants {
        static let PUBLIC_ROUTES_DATA_TABLE_NAME = "PublicRoutes";
    }
    
    /// Wie heissen unsere Tabellen in Core-Data?
    struct CoreDataTableNames {
        static let ROUTEN: String = "Routen";
        static let POINTS: String = "Points";
    }

}
