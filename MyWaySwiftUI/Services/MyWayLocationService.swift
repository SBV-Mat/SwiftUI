//
//  LocationServiceUpdateProtocol.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 25.03.2025.
//


//
//  LocationService.swift
//  MyWayMockup
//
//  Created by Erkan K. on 01.05.19.
//  Copyright © 2019 SBV-FSA. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

//Protocol (Interface), damit die aufrufenden Klassen ueber Heading und Location-Aenderungen informiert werden koennen
protocol LocationServiceUpdateProtocol: AnyObject {
    
    func locationDidUpdateToLocation(location : CLLocation);
    func locationDidUpdateHeading(heading: CLHeading, caller: String);
    func locationDidFailWithError(error: Error);
    func locationBeaconRanging(beacon: CLBeacon?)
    func locationDidLeaveRegion()
}

public class MyWayLocationService: NSObject {
    
    public static var sharedInstance = MyWayLocationService()
    
    // Array containing the observing objects
    var delegateObjects: [LocationServiceUpdateProtocol]
    var delegateLocUpdProto: LocationServiceUpdateProtocol!;
    private var caller = ""
//    private let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    private let locationManager: CLLocationManager;
    private let geocoder = CLGeocoder()
    private var beaconIdentifiers = [UUID]()
    private var locationDataArray: [CLLocation];
    
    // Settings
    private var useFilter: Bool
    private var shouldUpdateHeading: Bool
    private var lastLocationError: Error? //Der letzte  bekannte Fehler aufgerufen aus LocationManager
    private var locServiceCurrMagneticHeading: Double?
    private var isUpdatingLocation = false
    private var isUpdatingHeading = false
    private var locationStatus = "Not Started";
    private var shouldGetAdressOfUser = false
    private var currentAdress = ""
    private var mkPlacemarkOfCurrentAdress: MKPlacemark?;
    private weak var updateAddressTimer: Timer?;
    
    private var gpsMessageBadWasDisplayed = false;
    private var gpsLatLongInvalidWasDisplayed = false;
    
    let noAddressFound = NSLocalizedString("Keine Adresse gefunden", comment: "Homescreen - no Adress found to current location")
    let gpsAlertTitle = NSLocalizedString("Schwaches GPS-Signal", comment: "Title für Alert wenn GPS Signal schwach im LocService")
    let gpsAlertLongLattOld =  NSLocalizedString("Die Breiten- und Laengengrade sind veraltet. Keine zuverlässige Koordinate gefunden", comment: "Meldung wenn Long Latt abgelaufen schwach im LocService")
    let gpsAlertLongLattMinus =  NSLocalizedString("Die Breiten- und Laengengrade sind ungueltig. Keine zuverlässige Koordinate vorhanden. Bitte an einer anderen Stelle versuchen", comment: "Meldung wenn Long Latt horAccuracy minus im LocService")
    let gpsAlertLongLattNotGood =  NSLocalizedString("Die Breiten- und Laengengrade sind zu schwach. Keine zuverlässige Koordinate gefunden.", comment: "Meldung wenn Long Latt horAccuracy schwach im LocService")
    let gpsNoSignal =  NSLocalizedString("Kein Signal", comment: "GPS: Kein Signal");
    let gpsSchwach =  NSLocalizedString("Schwach", comment: "GPS: Schwach");
    let gpsDurchschnitt =  NSLocalizedString("Durchschnitt", comment: "GPS: Durchschnitt");
    let gpsGood =  NSLocalizedString("Gut", comment: "GPS: Gut");
    let gpsLocNull =  NSLocalizedString("Location ist NULL", comment: "GPS: Location Null");
    let gpsLocErrSearch =  NSLocalizedString("Fehler beim Suchen des Standorts", comment: "Fehler beim Suchen des Standorts");
    let gpsLocErrSearchMess =  NSLocalizedString("Fehler im Location-Manager. Die Navigation wurde aufgrund des Fehler beendet:", comment: "Fehler beim Suchen des Standorts Message");
    let gpsLocNotGiven =  NSLocalizedString("Standortfreigabe noch nicht erfolgt", comment: "Standortfreigabe noch nicht erfolgt");
    let gpsLocNotGivenMess =  NSLocalizedString("Sie haben leider MyWay noch keinen Zugriff gegeben Ihren Standort zu verwenden. Ihren Standort braucht MyWay, um eine Route abzuspeichern und um Sie auf einer Route richtig navigieren zu koennen. Die Berechtigung können Sie jederzeit in den Einstellungen anpassen. Danke.", comment: "Standortfreigabe noch nicht erfolgt Meldung");
    
    private class Config {
        var desiredAccuracy: CLLocationAccuracy?
        var distanceFilter: CLLocationDistance?
        var headingFilter: CLLocationDegrees?
        var activityType: CLActivityType?
        var shouldFilterLocation: Bool?
        var shouldStartUpdatingHeading: Bool?
        var shouldPauseLocationUpdatesAutomatically: Bool?
        var shouldGetAdresseOfUser: Bool?
        var caller: String?
    }
    
    private static let config = Config()
    
    /// Setup-Methode für den MyWay-Location Service. Hier werden die Location-Manager Parameter übergeben und für die jeweilige Instanz definiert. Die Parameter sind solange gueltig bis sie geändert oder von einer anderen Klasse überschrieben werden.
    ///
    /// - Parameters:
    ///   - desiredAccuracy: Genauigkeit, mit welchen Locations geliefert werden soll. Bei der Navigation und Routenerfassung verwenden wir die beste Genauigkeit: kCLLocationAccuracyBestForNavigation
    ///   - distanceFilter: Definiert, ab wie vielen Metern ein Location-Update erfolgen soll. Default 5.0
    ///   - headingFilter: Definiert, ab welcher Gradänderung ein Update erfolgen soll. Default 10.0
    ///   - activityType: Definiert, wie der User unterwegs ist. Default CLActivityType.otherNavigation. Damit auch die Punkte dort gesetzt werden wo sich der User befindet
    ///   - shouldFilterLocation: Angabe, ob die gefundenen Locations einer Qualitätskontrolle unterzogen werden sollen. Sprich überprüfen ob die Werte gueltig sind oder nicht. Wenn Nein, werden alle Locations genommen. Bei Ja, wird die Genauigkeit überprüft. Default = true
    ///   - shouldStartUpdatingHeading: Angabe, ob Heading-Updates erfolgen sollen. Bei Routenerfassung und Navigation auf TRUE gesetzt.
    ///   - shouldPauseLocationUpdatesAutomatically: Angabe, ob automatisch gestoppt werden soll, falls keine Locations geliefert werden. Default auf TRUE
    ///   - shouldGetAdressOfUser: Angabe, ob ein Timer laufen soll, welche in einem bestimmten Intervall die aktuelle Adresse des Users suchen soll. Default auf TRUE.
    ///   - caller: Die Aufrufende Klasse. Damit wir überprüfen können wer den Service gerade verwendet. Falls Caller = AppDelegate, dann koennen wir den LocationManager im Background-Modus herunterfahren.
    class func setup(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, headingFilter: CLLocationDegrees, activityType: CLActivityType, shouldFilterLocation: Bool, shouldStartUpdatingHeading: Bool, shouldPauseLocationUpdatesAutomatically: Bool, shouldGetAdressOfUser: Bool, caller: String) {
        
        MyWayLocationService.config.desiredAccuracy = desiredAccuracy;
        MyWayLocationService.config.distanceFilter = distanceFilter;
        MyWayLocationService.config.headingFilter = headingFilter;
        MyWayLocationService.config.activityType = activityType;
        MyWayLocationService.config.shouldFilterLocation = shouldFilterLocation;
        MyWayLocationService.config.shouldStartUpdatingHeading = shouldStartUpdatingHeading;
        MyWayLocationService.config.shouldPauseLocationUpdatesAutomatically = shouldPauseLocationUpdatesAutomatically;
        MyWayLocationService.config.shouldGetAdresseOfUser = shouldGetAdressOfUser;
        MyWayLocationService.config.caller = caller;
        //Damit wir es (falls andere Klasse Parameter aktualisiert) auch gleich setzen können lokal
        MyWayLocationService.sharedInstance.setNewParameterForLocationManager();
    }
    
    //Wird jeweils nur beim ersten Initialisieren aufgerufen. Daher rufen wir in der setup-Methode fnktionen auf um Parameter von Location-Manager dann wieder aufzusetzen
    //Prevent other classed from making multiple instances
    private override init() {
        
        //Hier Kontrolle, ob auch alle Parameter gesetzt wurden. So können wir den Verwender zwingen das er gewisse Parameter setzen muss
        guard let desiredAccuracyParam = MyWayLocationService.config.desiredAccuracy else {
            fatalError("Error - you must call configDesiredAccuracy before accessing MyWayLocationService.shared")
        }
        
        guard let distanceFilterParam = MyWayLocationService.config.distanceFilter else {
            fatalError("Error - you must call configDistanceFilter before accessing MyWayLocationService.shared")
        }
        
        guard let headingFilterParam = MyWayLocationService.config.headingFilter else {
            fatalError("Error - you must call configHeading Filter before accessing MyWayLocationService.shared")
        }
        
        guard let activityTypeParam = MyWayLocationService.config.activityType else {
            fatalError("Error - you must call configActivityType before accessing MyWayLocationService.shared")
        }
        
        guard let shouldFilterLocationParam = MyWayLocationService.config.shouldFilterLocation else {
            fatalError("Error - you must call configShouldFilterLocation before accessing MyWayLocationService.shared")
        }
        
        guard let shouldStartUpdatingHeading = MyWayLocationService.config.shouldStartUpdatingHeading else {
            fatalError("Error - you must call shouldStartUpdatingHeading before accessing MyWayLocationService.shared")
        }
        
        guard let shouldPauseLocationUpdatesAutomatically = MyWayLocationService.config.shouldPauseLocationUpdatesAutomatically else {
            fatalError("Error - you must call configShouldPauseLocationUpdatesAutomatically before accessing MyWayLocationService.shared")
        }
        
        guard let shouldStartGettingAdressOfUser = MyWayLocationService.config.shouldGetAdresseOfUser else {
            fatalError("Error - you must call configShouldGetAdresseOfUser before accessing MyWayLocationService.shared")
        }
        
        guard let callerParam = MyWayLocationService.config.caller else {
            fatalError("Error - you must call caller before accessing MyWayLocationService.shared")
        }
        
        caller = callerParam;
        
        //Regular initialisation using param
        locationManager = CLLocationManager()
        
        //Um die bestmögliche Genauigkeit zu erreichen. Wir sagen dem LocationManager das er sein bestes versuchen soll eine gute Genauigkeit zurückzubekommen. Fuer die Navigation ist der Default "kCLLocationAccuracyBestForNavigation". Bemerkung: Fuer desiredAccuracy sollten wir immer die minimalste Accuracy nehmen, welche wir benoetigen. Warum? Angenommen wir wollen nur die Genauigkeit von ein paar Hundert Metern, dann kann LocationManager Phone Cells und WLANs zu Hilfe ziehen um die aktuelle Position herauszufinden. Das spart den Akku. Aber falls man eine bessere Genauigkeit benötigt, sollte man zB kCLLocationAccuracyBestForNavigation benutzen, damit der Locationmanager GPS benutzt. Man sollte auch aufhoeren LocationManager zu aktualisieren wenn man einen guten Wert hat, damit nicht immer gesucht wird nach einer Location.
        locationManager.desiredAccuracy = desiredAccuracyParam;
        
        //Nur alle XY Meter soll ein Resultat geliefert werden. Es ist hierbei wichtig, dass der User sich bewegt. Erst danach kommt ein Update. Default ist 5 Meter. Mit filter=kCLDistanceFilterNone bekommen wir immer ein update.
        locationManager.distanceFilter = distanceFilterParam;
        
        //Damit der GPS-Punkt nicht an eine Strasse angeführt wird (SNAP TO ROAD) und wirklich dort gesetzt wird wo wir uns auch befinden!! Als Default nehmen wir CLActivityType.otherNavigation (Bei der Routenaufnahme und Ablaufen der Navigation);
        locationManager.activityType = activityTypeParam
        
        //Nur alle XY-Grad-Aenderung soll ein Update erfolgen. Default sind 10 eingestellt (zum Beispiel bei der Navigation)
        locationManager.headingFilter = headingFilterParam;
        locationManager.requestWhenInUseAuthorization();
        
        //Damit wir Location-Updates erhalten wenn das Iphone im Sperrbildschirm etc. ist. Benötigt den Eintrag in PLIST: "Privacy - Location Always Usage Description" & Bei Projekteinstellungen unter Capabilities Background-Mode "Location-Updates"
        locationManager.allowsBackgroundLocationUpdates = true;
        
        //Default Nein, damit wir immer Location-Updates erhalten. YES, damit wir Batterie sparen. Wenn keine signifikanten Location-Updates, dann wird Apple automatisch pausieren bei YES! So machen wir es bei AppDelegate
        locationManager.pausesLocationUpdatesAutomatically = shouldPauseLocationUpdatesAutomatically;
        locationDataArray = [CLLocation]();
        useFilter = shouldFilterLocationParam;
        shouldUpdateHeading = shouldStartUpdatingHeading;
        shouldGetAdressOfUser = shouldStartGettingAdressOfUser;
        delegateObjects = [LocationServiceUpdateProtocol]()
        super.init();
        locationManager.delegate = self;
    }
    
    /// Damit wir bei einer weiteren Instanz die neuen Parameter setzen koennen
    private func setNewParameterForLocationManager() {
        
        //Rückfrage, ob der App vertraut werden soll, weil wir immer einen Update der App brauchen. Da wir im Hintergrund die Location (Bei Navigation) benoetigen
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization();
        }
        
        //Falls Berechtigung noch nicht erteilt, dann Ausstieg
        if(CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus()
           == .denied || CLLocationManager.authorizationStatus() == .notDetermined) {
            
            //Falls hier irgendwelche Timer bereits laufen sollten, Ausstieg
            if isUpdatingLocation {
                self.stopUpdatingLocation();
            }
            return;
        }
        
        //Hier den Timer starten, falls wir das Holen der aktuellen Adresse benoetigen
        locationManager.distanceFilter = MyWayLocationService.config.distanceFilter!;
        locationManager.desiredAccuracy = MyWayLocationService.config.desiredAccuracy!;
        locationManager.headingFilter =  MyWayLocationService.config.headingFilter!;
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.pausesLocationUpdatesAutomatically = MyWayLocationService.config.shouldPauseLocationUpdatesAutomatically!;
        locationManager.activityType = MyWayLocationService.config.activityType!;
        useFilter = MyWayLocationService.config.shouldFilterLocation!;
        shouldUpdateHeading = MyWayLocationService.config.shouldStartUpdatingHeading!;
        shouldGetAdressOfUser = MyWayLocationService.config.shouldGetAdresseOfUser!;
        caller = MyWayLocationService.config.caller!;
        
        //Falls locationManager neu gestartet werden muss, weil wir zuvor beendet haben
        if(isUpdatingLocation == false || (isUpdatingHeading == false && shouldUpdateHeading == true)) {
            self.startUpdatingLocationService()
        }
    }
    
    /// Kontrolle, ob Objekt bereits registriert wurde als Observer
    /// - Parameter object: OBjekt, welche kontrolliert werden soll ob bereits registriert
    /// - Returns: True, wenn Objekt bereits registriert wurde als Delegate
    func isAlreadyRegistredDelegate(for object: LocationServiceUpdateProtocol) -> Bool {
        var isAlreadyRegistred = false
        
        if(delegateObjects.count == 0) {
            return false;
        }
        
        for i in 0..<delegateObjects.count {
            if delegateObjects[i] === object {
                isAlreadyRegistred = true;
                break;
            }
        }
        
        return isAlreadyRegistred;
    }
    
    func addNewDelegateObject(for object: LocationServiceUpdateProtocol) {
        let objectAlreadyInserted = isAlreadyRegistredDelegate(for: object)
        
        //Nur hinzufügen, falls noch nicht hinzugefügt
        if !objectAlreadyInserted {
            delegateObjects.append(object)
        }
    }
    
    func getNumCurrentDelegateObjects() -> Int {
        return delegateObjects.count;
    }
    
    func clearDelegateObjects() {
        delegateObjects.removeAll(keepingCapacity: true);
    }
    
    // Call this function to stop position information for an object
    func removeDelegateObject(for object: LocationServiceUpdateProtocol) {
        for i in 0..<delegateObjects.count {
            // Removes identical (not equal) objects from observer
            if delegateObjects[i] === object {
                delegateObjects.remove(at: i);
                break;
            }
        }
    }
    
    /// Location-Parameter auf Default-Werte zurücksetzen
    func setLocationManagerParameterToDefault() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = 5.0;
        locationManager.headingFilter = 10.0;
        locationManager.activityType = CLActivityType.otherNavigation
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.pausesLocationUpdatesAutomatically = false;
    }
    
    /// Starten von Location-Updates. Falls auf TRUE wird hier auch Heading-Update gestartet und der Timer gestartet für die Suche nach der aktuellen Adresse
    private func startUpdatingLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            //Ein delegate ist hier nicht notwendig
            locationManager.startUpdatingLocation();
            self.isUpdatingLocation = true;
            if(shouldUpdateHeading == true && self.isUpdatingHeading == false) {
                locationManager.startUpdatingHeading();
                isUpdatingHeading = true;
            }
            
            //Alle 23 Sekunden soll gecheckt werden, welche Adresse der User sich befindet
            if(shouldGetAdressOfUser == true) {
                updateAddressTimer = Timer.scheduledTimer(timeInterval: 31, target: self, selector: #selector(setCurrentAdressOfUser), userInfo: nil, repeats: true);
                
                //Damit wir auch sicher sein koennen das wir eine Adresse haben, warten wir eine Sekunde und starten den Timer daraufhin
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.updateAddressTimer?.fire();
                })
            } else {
                updateAddressTimer?.invalidate();
            }
        } else {
            
            //Dem User anzeigen, das er MyWay berechtigen soll Location-Updates zuzulassen
            showTurnOnLocationServiceAlert()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation();
        isUpdatingLocation = false;
        
        if isUpdatingHeading {
            locationManager.stopUpdatingHeading();
            isUpdatingHeading = false;
        }
        
        if shouldGetAdressOfUser {
            updateAddressTimer?.invalidate();
        }
        
        //Bereinigen der Location
        self.cleanUpOldLocations();
        
//        if appDelegate.isObservingPoisOnHomeScreen() {
//            appDelegate.startWatchingPoisFromHomeScreen();
//        } else {
//            if(MyWayLocationService.sharedInstance.caller != "AppDelegate") {
//                
//                //Wir fahren runter mit Location-Manager-Performance und der Häufigkeit wie oft Location gesucht wird und starten den Location-Manager (Default) aus App-Delegate
//                appDelegate.startLocationService();
//            }
//        }
    }
    
    /// Kontrolle, ob Location-Manager location-updates liefert oder nicht
    ///
    /// - Returns: True, wenn LocationManager am laufen ist und Location-Updates liefert
    func checkIfLocationManagerIsRunning() -> Bool {
        return isUpdatingLocation
    }
    
    /// Kontrolle, ob Location-Manager Heading-Updates liefert oder nicht
    ///
    /// - Returns: True, wenn LocationManager am laufen ist und Heading-Updates liefert
    func checkIfLocationManagerIsUpdatingHeading() -> Bool {
        return isUpdatingHeading
    }
    
    /// Holen der zuletzt gefundenen Location
    ///
    /// - Returns: die zuetzt gefundene (aktuelle) Location
    func getCurrentLocation() -> CLLocation? {
        if(locationDataArray.count == 0) {
            return nil;
        }
        return locationDataArray.last
    }
    
    /// Cleanup der Locations-Array, welche bei jedem neuen Location inserted wird. Damit nicht viel Memory aufgebaut wird und die alten Location-Daten bereinigt werden koennen.
    private func cleanUpOldLocations() {
        if(locationDataArray.count == 0) {
            return;
        }
        
        if(locationDataArray.count > 10) {
            
            //1. wegsichern aktuelle Location
            let savedLastLoc = getCurrentLocation();
            
            //2. Bereinigen Array mit Locations. keepingCapacity auf True, damit die Grösse beibehalten wird, da wir es ja wieder fuellen. Ist auch performanter.
            locationDataArray.removeAll(keepingCapacity: true);
            
            //3. Wir fuellen auch gleich die aktuelle Location, damit wir auch wieder eine Location haben
            if let lastLoc = savedLastLoc {
                locationDataArray.append(lastLoc);
            }
        }
    }
    
    func getCurrentCaller() -> String {
        return caller;
    }
    
    /// Kontrolle, ob der User sich bewegt. Brauchen wir u.a. bei Aufnahme der automatischen Routenpunkte. Damit wir auch nur Punkte aufnehmen wenn sich der User auch bewegt. Die Durchschnitts-Gehgeschwindigkeit eines Sehenden Menschens liegt bei 1m/s oder 3.6km/h. Daher nehmen wir hier 1.8km/h, da blinder/sehbehinderter langsamen läuft
    ///
    /// - Parameter locationManager: die aktuelle LocationManager
    /// - Returns: True, wenn sich der User bewegt
    func isUserMoving() -> Bool {
        var userIsMoving = false;
        
        if let loc = locationManager.location {
            if (loc.speed * 3.6) >= MyWayConstants.LocationConstants.MINIMUM_SPEED_FOR_COURSE {
                userIsMoving = true;
            }
        }
        return userIsMoving;
    }
    
    // Gets Direction depending on Speed (Corse or magnetig heading
    func getDirection() -> Double? {
        if isUserMoving() {
            if let loc = getCurrentLocation() {
                return loc.course
            } else {
                return getCurrentMagneticHeading()
            }
        } else {
            return getCurrentMagneticHeading()
        }
    }
    
    func getCurrentMagneticHeading() -> CLLocationDirection? {
        return locServiceCurrMagneticHeading
    }
    
    /// Liefert die aktuelle Adresse im Format "Könizstrasse 23, 3008 Bern, Schweiz". Damit die Adresse auch gesucht wird, muss beim Setup des MyWayLocationService der Parameter shouldGetAdressOfUser auf TRUE gesetzt werden. Die Adresse wird alle paar Sekunden mit einem Timer geholt.
    /// - Returns: Die aktuelle Adresse des Users im Format Könizstrasse 23, 3008 Bern, Schweiz
    func getCurrentAdress() -> String {
        return self.currentAdress;
    }
    
    /// Liefert den Placemark einer Adresse zurück. Brauchen wir unter Anderem in der Klasse NavigationVonNachViewController um die einzelnen Routenanweisungen zu berechnen
    ///
    /// - Returns: Placemark im Format MKPlacemark
    func getCurrentMkPlacemark() -> MKPlacemark? {
        return mkPlacemarkOfCurrentAdress;
    }
    
    /// ReverseGeoCodeLocation: Aufschluesselung der Location-Koordinate in eine Userfreundliche Adressangabe. Aus einer Koordinate wird dann das Format "Könizstrasse 23, 3008 Bern, Schweiz".
    @objc internal func setCurrentAdressOfUser() {
        if(locationDataArray.count == 0) {
            return;
        }
        
        //Hier Kontrolle, ob ich eine MindestDistanz zurückgelegt habe, zwischen Distanz vom letzten Placemark und der neuen Koordinate
        if(self.mkPlacemarkOfCurrentAdress?.coordinate != nil) {
            
            //Falls keine Distanz von 20 Metern zurückgelegt wurde, dann ausstieg. Damit nicht immer eine neue Adresse geholt werden muss
            
            //Ausstieg, falls Distanz, welche zurückgelegt wurde weniger als 20 Meter entfernt.
            if(self.mkPlacemarkOfCurrentAdress!.location!.distance(from: locationDataArray.last!) < 20.0) {
                
                //Ausstieg, da wir keine Distanz von Mindestens 10 metern zurückgelegt haben
                //  self.mkPlacemarkOfCurrentAdress?.location?.timestamp.time
                return;
            }
        }
        
        //Wegsichern des alten Placemarks und Adresse
        let oldPlacemarkLocation = self.mkPlacemarkOfCurrentAdress;
        let oldCurrentAdress = self.currentAdress;
        
        //Um eien Adresse richtig aufloesen zu könenn braucht es eine funktionierende Network-Verbindung. Auch ist die Abfrage limitiert, so duerfen (laut Apple) nur eine einzige Anfrage pro Minute abgesetzt werden
        geocoder.reverseGeocodeLocation(self.getCurrentLocation()!,
                                        completionHandler: {(placemarks:[CLPlacemark]?, error:Error?) -> Void in
            
            if(error != nil) {
                self.currentAdress = oldCurrentAdress;
                //self.currentAdress = "Fehler: Keine Adresse gefunden. \(error!.localizedDescription)";
                
                self.mkPlacemarkOfCurrentAdress = oldPlacemarkLocation;
            } else if (placemarks == nil) || (placemarks!.isEmpty) {
                self.currentAdress = self.noAddressFound;
                self.mkPlacemarkOfCurrentAdress = oldPlacemarkLocation;
            } else {
                //Wir haben eine gültige Adresse, formatieren und Ausgabe
                let placemark = placemarks?.last;
                self.currentAdress = self.formatAddressFromPlacemark(placemark!);
                self.mkPlacemarkOfCurrentAdress = MKPlacemark(placemark: placemark!);
            }
        })
    }
    
    /// Formatierung der Adresse
    ///
    /// - Parameter placemark: Placemark CLPlacemafrk
    /// - Returns: Formatierte Adresse
    internal func formatAddressFromPlacemark(_ placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joined(separator: ", ")
    }
    
    /// Kontrolle, ob die Signalstaerke ausreichend ist. Brauchen wir bevor wir Punkte hinzufuegen oder mit der Navigation starten. BEdeutung der einzelnen Signalwerte:
    /// 1. <0: Kein Signal
    /// 2. >163: Schwaches Signal
    /// 3. 48 - 163: Durchschnittssignal
    /// 4. 0-47: Gutes Signal
    ///
    /// - Returns: True, wenn die Signalstärke ausreichend ist
    func checkSignalStrenghtOfGPS()->Bool {
        var signalStrengthEnough = true;
        if let horAccuracy = self.locationManager.location {
            
            //Falls kein Signal oder schlechter als Durchschnittssignal, dann ist unser GPS-Signal nicht ausreichend
            if(horAccuracy.horizontalAccuracy.isZero == true || horAccuracy.horizontalAccuracy >= 163 || horAccuracy.horizontalAccuracy < 0) {
                signalStrengthEnough = false;
            }
        } else {
            
            //Falls Location-Manager Null ist
            signalStrengthEnough = false;
        }
        return signalStrengthEnough;
    }
    
    func getGpsSignalStrengthText() -> String {
        var gpsText = gpsNoSignal;
        
        //Quelle fuer Bedeutung der Werte für Signalstaerke:
        //https://stackoverflow.com/questions/10583449/xcode-how-to-show-gps-strength-value
        //1. <0: Kein Signal
        //2. >163: Schwaches Signal
        //3. 48 - 163: Durchschnittssignal
        //4. 0-47: Gutes Signal
        if let currLocation = self.locationManager.location{
            if(currLocation.horizontalAccuracy < 0) {
                gpsText = gpsNoSignal;
            } else if (currLocation.horizontalAccuracy >= 163) {
                gpsText = gpsSchwach;
            } else if(currLocation.horizontalAccuracy >= 48 && currLocation.horizontalAccuracy < 163) {
                gpsText = gpsDurchschnitt;
            } else if(currLocation.horizontalAccuracy > 0 && currLocation.horizontalAccuracy < 48) {
                gpsText = gpsGood;
            } else {
                gpsText = gpsNoSignal;
            }
        } else {
            gpsText = gpsLocNull;
        }
        return "GPS: \(gpsText)";
    }
    
    func getGpsHorizontalAccuracy() -> CLLocationAccuracy {
        var locationAccuracy: CLLocationAccuracy = 0.0;
        
        if let currLocation = self.locationManager.location {
            locationAccuracy = currLocation.horizontalAccuracy;
        }
        return locationAccuracy;
    }
    
    func checkIfLocationManagerIsInFullPowerMode()-> Bool {
        return locationManager.distanceFilter <= 3 && locationManager.activityType == CLActivityType.otherNavigation && locationManager.headingFilter <= 10 && locationManager.pausesLocationUpdatesAutomatically == false
    }
    
    /// Liefert die Genauigkeit der aktuellen Location. Brauchen wir zur Bestimmung wie zuverlässig der Wert ist.
    ///
    /// - Returns: Genauigkeit der aktuellen Location
    func getLocationManagerDesiredAcurracy() -> CLLocationAccuracy {
        return locationManager.desiredAccuracy
    }
    
    /// Liefert die Distanz in Meter. Dies ist die Minimaldistanz, welche der User zurücklegen muss, damit wir Location-Updates erhalten
    ///
    /// - Returns: Distanzfilter in Meter
    func getLocationManagerDistanceFilter()-> CLLocationDistance {
        return locationManager.distanceFilter;
    }
    
    /// Liefert Activity-Type des Users, das heisst mit welchen Mitteln (Flugzeug, zu Fuss, Auto etc)  er unterwegs ist. Wir verwenden per Default otherNavigation.
    ///
    /// - Returns: Activity-Type des Users
    func getLocationManagerActivityType()-> CLActivityType {
        return locationManager.activityType;
    }
    
    /// Liefert die aktuell eingestellte HeadingFilter-Information, das heisst wie viel Grad der User das Handy drehen muss damit neue Events generiert werden
    ///
    /// - Returns: Die aktuell eingestellte Heading-Filter für den laufenden Location-Manager
    func getLocationManagerHeadingFilter()-> CLLocationDegrees {
        return locationManager.headingFilter;
    }
    
    @available(iOS 13.0, *)
    func startBeaconMonitoring(uuids: [String]) {
        for uuid in uuids {
            let uuidValue = UUID(uuidString: uuid)!
            let r = CLBeaconIdentityConstraint(uuid: uuidValue)
            self.beaconIdentifiers.append(uuidValue)
            locationManager.startRangingBeacons(satisfying: r)
        }
    }
    
    @available(iOS 13.0, *)
    func stopBeaconMonitoring() {
        for r in beaconIdentifiers {
            locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: r))
        }
        beaconIdentifiers.removeAll()
    }
    
}

extension MyWayLocationService: CLLocationManagerDelegate {

    //MARK: CLLocationManagerDelegate protocol methods
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]){
        lastLocationError = nil;
        
        if let newLocation = locations.last {
            var locationAdded: Bool;
            
            if useFilter {
                
                //Wir wollen das die gelieferte Location auf bestimmte Qualität geprueft wird
                locationAdded = filterAndAddLocation(newLocation);
            } else {
                
                //Wir wollen keine Validierung der Location, sondern einfach die gefunden Locations hinzufügen
                locationDataArray.append(newLocation);
                locationAdded = true
            }
            
            if (locationAdded == true){
                
                //Vorerst keine Meldung
                //    notifiyDidUpdateLocation(newLocation: newLocation)
                
            }
            
        }
    }
    
    //Auch Heading-Aenderungen soll er melden
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        //Ausstieg, da heading ungueltig
        if(newHeading.headingAccuracy < 0) {
            // TODO LB: Prüfen ob Fehlermeldung, falls ja, noch übersetzen.
            /**
            if UIAccessibility.isVoiceOverRunning {
                if(UIApplication.shared.applicationState != .background) {
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "Richtungsangabe nicht verfuegbar. Kann sein wenn Device nicht kalibriert oder interferenzen im lokalen magnetischen Feld");
                } else {
                    //Hier im Hintegrund sprechen. Zuvor noch die Funktion zentralisieren...
                }
            } else if(UIAccessibility.isVoiceOverRunning == false && UIApplication.shared.applicationState != .background) {
                
                //Meldung anzeigen für die Sehenden User
                GeneralUtil.displayDismissAlert(alertTitle: "Keine Richtungsangabe vorhanden", alertMessage: "Richtungsangabe nicht verfuegbar. Kann sein wenn Device nicht kalibriert oder interferenzen im lokalen magnetischen Feld", animated: true, viewController: nil)
            }
            */
            return;
        }
        
        DispatchQueue.main.async() { () -> Void in
            //Meldung an Delegate, dass Heading-Update vorhanden
            //Alte Version
            self.locServiceCurrMagneticHeading = newHeading.magneticHeading;
            for d in self.delegateObjects {
                d.locationDidUpdateHeading(heading: newHeading, caller: self.getCurrentCaller())
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false;
        var deniedOrRestricted = false;
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
            deniedOrRestricted = true
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
            deniedOrRestricted = true
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        case CLAuthorizationStatus.authorizedAlways:
            locationStatus = "Status authorized always"
            shouldIAllow = true;
        case CLAuthorizationStatus.authorizedWhenInUse:
            locationStatus = "Status authorized when in use"
            shouldIAllow = true;
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LabelHasbeenUpdated"), object: nil);
        
        if (shouldIAllow == true && self.isUpdatingLocation == false) {
            
            // Wir haben die Erlaubnis erhalten Location zu aktualisieren. Also Parameter neu definieren und location-services starten
            self.setNewParameterForLocationManager()
        } else if(deniedOrRestricted == true) {
            showTurnOnLocationServiceAlert()
        }
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true;
    }
    
    /// Richtwerte (Quelle Internet) für die Wertigkeit der Signalstaerke
    ///  1. <0: Kein Signal
    ///  2. >163: Schwaches Signal
    ///  3. 48 - 163: Durchschnittssignal
    ///  4. 0-47: Gutes Signal
    ///
    /// - Parameter location: die neue gefundene Location
    /// - Returns: die validierte Location
    func filterAndAddLocation(_ location: CLLocation) -> Bool{
        
        //1: Falls die Zeit in der wie ein Location-Update erhalten haben mehr als 10 Sekunden zurückliegt, dann haben wir es mit einem Cache-Result zu tun. Anstelle das wir irgendeinen fixen Location zurückgeben, ignorieren wir diese Location-Werte und Ausstieg. Quelle: Wenderlich und Medium
        
        if (location.timestamp.timeIntervalSinceNow < -10) { return false }
        
        //2: Falls die neu gefundenen Locations zu ungenau sind (weniger als 0) dann ignorieren wir diese
        if (location.horizontalAccuracy < 0) {
            if(gpsLatLongInvalidWasDisplayed == true) {
                return false;
            }
            if(UIAccessibility.isVoiceOverRunning == true) {
                gpsLatLongInvalidWasDisplayed = true;
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: gpsAlertLongLattMinus);
            } else if(UIAccessibility.isVoiceOverRunning == false && UIApplication.shared.applicationState != .background) {
                
                gpsLatLongInvalidWasDisplayed = true
                //Meldung anzeigen für die Sehenden User
                GeneralUtil.displayDismissAlert(alertTitle: gpsAlertTitle, alertMessage: gpsAlertLongLattMinus, animated: true, viewController: nil)
            }
            return false;
        }
        
        if (location.horizontalAccuracy >= MyWayConstants.LocationConstants.DESIRED_LOCATION_ACCURACY_BAD) {
            if(gpsMessageBadWasDisplayed == false) {
                
                //Schwaches Signal
                if(UIAccessibility.isVoiceOverRunning == true) {
                    gpsMessageBadWasDisplayed = true;
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: gpsAlertLongLattNotGood);
                } else if(UIAccessibility.isVoiceOverRunning == false && UIApplication.shared.applicationState != .background) {
                    gpsMessageBadWasDisplayed = true;
                    
                    //Meldung anzeigen für die Sehenden User
                    GeneralUtil.displayDismissAlert(alertTitle: gpsAlertTitle, alertMessage: gpsAlertLongLattNotGood, animated: true, viewController: nil)
                }
            }
            //return false;
        }
        
        if(location.horizontalAccuracy >= MyWayConstants.LocationConstants.DESIRED_LOCATION_ACCURACY_AVERAGE && location.horizontalAccuracy < MyWayConstants.LocationConstants.DESIRED_LOCATION_ACCURACY_BAD) {
            
            //"Durchschnittssignal. Nichts tun";
            //WIeder zurücksetzen, damit bei allfälliger schwacher Signalstärke Message wieder ausgegeben wird
            gpsMessageBadWasDisplayed = false;
            gpsLatLongInvalidWasDisplayed = false;
        }
        
        if(location.horizontalAccuracy > 0 && location.horizontalAccuracy < MyWayConstants.LocationConstants.DESIRED_LOCATION_ACCURACY_AVERAGE) {
            
            //"Gutes Signal";
            //WIeder zurücksetzen, damit bei allfälliger schwacher Signalstärke Message wieder ausgegeben wird
            gpsMessageBadWasDisplayed = false;
            gpsLatLongInvalidWasDisplayed = false;
        }
        
        //Location Qualität ist gültig. Die neue Location wird unserer Location-Array angefuegt. Auch schwache Locations nehmen wir auf, damit die Adress-Navigation bearbeitet werden kann.
        locationDataArray.append(location);
        
        //let userInfo : NSDictionary = ["location" : location]
        DispatchQueue.main.async() { () -> Void in
            
            //let kLocationDidChangeNotification = "LocationDidChangeNotification"
            //Alte Version
            //self.delegateLocUpdProto.locationDidUpdateToLocation(location: location);
            
            //NotificationCenter.default.post(name: Notification.Name(kLocationDidChangeNotification), object: self, userInfo: userInfo as [NSObject : AnyObject])
            
            
            for d in self.delegateObjects {
                d.locationDidUpdateToLocation(location: location)
            }
        }
        
        return true;
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        
        //1. Falls Location nicht bekannt, dann nicht eingehen auf den Fehler
        //The CLError.locationUnknown error means the location manager was unable to obtain a location right now, but that doesn’t mean all is lost. It might just need another second or so to get an uplink to the GPS satellite. In the mean time it’s letting you know that, for now, it could not get any location information. When you get this error, you will simply keep trying until you do find a location or receive a more serious error.
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return;
        }
        
        lastLocationError = error;
        
        //2. Check, ob User uns Berechtigung erteilt die App auf Location-Updates zu erlauben. Wenn Nein, geben wir ihme eine Meldung aus
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == CLError.Code.denied.rawValue{
            showTurnOnLocationServiceAlert();
        }
        
        //3. Alle anderen Fehler zeigen wir in seiner Sprache als Alert an
        GeneralUtil.displayAlert(alertTitle: gpsLocErrSearch, alertMessage: "\(gpsLocErrSearchMess) \(error.localizedDescription)", animated: true, viewController: nil)
        
        //4. Den Delegate Methoden mitteilen das ein Fehler aufgetreten ist
        DispatchQueue.main.async() { () -> Void in
            
            //self.delegateLocUpdProto.locationdidFailWithError(error: error);
            
            for i in 0..<self.delegateObjects.count {
                self.delegateObjects[i].locationDidFailWithError(error: error)
            }
        }
        
        //5. Stoppen der Location-Manager
        stopUpdatingLocation();
    }
    
    func showTurnOnLocationServiceAlert(){
        GeneralUtil.displayAlert(alertTitle: gpsLocNotGiven, alertMessage: gpsLocNotGivenMess, animated: true, viewController: nil);
    }
    
    func notifiyDidUpdateLocation(newLocation:CLLocation){
        NotificationCenter.default.post(name: Notification.Name(rawValue:"didUpdateLocation"), object: nil, userInfo: ["location" : newLocation]);
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let r = region as? CLBeaconRegion {
            print("did enter region \(region)")
            locationManager.startRangingBeacons(in: r)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let r = region as? CLBeaconRegion {
            locationManager.stopRangingBeacons(in: r)
            for d in self.delegateObjects {
                d.locationDidLeaveRegion()
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if #available(iOS 13.0, *) {
            
            // 1. Filter out unknown beacons
            let filteredBeacons = beacons.filter { beacon in
                return beacon.proximity.rawValue > 0
            }
            // 2. Select last (nearest) beacon or else nil
            let foundBeacon = filteredBeacons.isEmpty ? nil : filteredBeacons.first!
            
            for d in self.delegateObjects {
                d.locationBeaconRanging(beacon: foundBeacon)
            }
            
            /*
            for b in beacons {
                print("Found Beacon: \(b.uuid), \(b.major), \(b.minor), \(b.accuracy) \(b.proximity), \(b.proximity.rawValue)")
            }
            print("---------------------------------------\n")
            */
            
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }
    
    //Falls wir ueberprüfen wollen, wie der User unterwegs ist anhand seiner Aktivität
    //Wird momentan nicht verwendet
    //Achtung: braucht viel Performance
    /*
     private func startActivityManager(){
     
     //Falls nicht verfügbar, dann rausgehen....
     
     if(!CMMotionActivityManager.isActivityAvailable()){
     
     return;
     
     }
     
     
     
     activityManager = CMMotionActivityManager();
     activityManager?.startActivityUpdates(to: OperationQueue.main) {
     [weak self] (activity: CMMotionActivity?) in
     
     guard let activity = activity else { return }
     DispatchQueue.main.async {
     // only interested in activities that were of at least medium confidence
     
     if activity.confidence == .medium || activity.confidence == .high {
     
     
     if activity.walking {
     
     // self?.lblTotalDistance.text = "Status: Am Laufen";
     
     
     } else if activity.stationary {
     
     // self?.lblTotalDistance.text = "Stationary";
     
     
     } else if activity.running {
     
     // self?.lblTotalDistance.text = "Running";
     } else if activity.automotive {
     
     // self?.lblTotalDistance.text = "Automotive";
     }
     }
     }
     }
     }
     */
    
}
