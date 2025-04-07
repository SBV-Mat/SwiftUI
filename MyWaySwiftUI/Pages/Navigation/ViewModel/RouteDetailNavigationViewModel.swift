//
//  RouteDetailNavigationViewModel.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//

import Foundation
import MapKit

class RouteDetailNavigationViewModel: ObservableObject {
    
    //MARK: - Declaration-Section
    var swipeLeftActionAccessSetCurrPoint: UIAccessibilityCustomAction?
    var currentSelectedVoiceOverCellIndex = 0
    var indexOfCurrentPointInTable = 0
    var quickestRouteForSegmentFromDirection: MKRoute?
    var navigation: NavigationObject?
    
    private var convertedDBPoints = [Point]()
    private var currentPointWasManuallySet = false
    private var currentPointIndexOfManuallySet = 0
    private var currentAdress = "NO ADRESS FOUND"
    
    // Variables for presentation
    private var shouldColorDistanceRoutePoint = true
    private var saveEditBtnPressed = false
    private var exportBtnPressed = false
    
    //Routen-Info
    internal var routeName = ""
    internal var routeLongDescription = ""
    internal var artRouteIdOfRoute: Int64 = 0
    internal var indexOfSelectedRoute = 0
    internal var crtdDateOfRoute = ""
    internal var importedRoute = false
    internal var routeType = ""
    internal var pointsOfRoute: [Point]?
    //    internal var beaconsOfRoute: [Beacons]?
    internal var pointsFromNavigation: [Point] = [];
    internal var beaconAlertController: UIAlertController?
    //    internal var lastShownBeacon: Beacons?
    internal var beaconFoundTime: Date?
    internal var beaconWaitToEndOfSpeech = false
    internal let removeBeaconTimeout = 5.0
    
    var comesFromAdressNavigation = false
    private var selectedAnnotation: MKPointAnnotation?
    private var pointsSortedInDescendingOrder = false
    //    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    //    let dataStore = CoreDataManager.sharedManager
    //    let locationService = MyWayLocationService.sharedInstance
    let REGION_RADIUS_FOR_MAPS: CLLocationDistance = 100;
    internal var currentLocation: CLLocation?;
    internal var lastKnownHeading: CLLocationDirection?
    //internal var updatingLocation = false;
    internal var lastLocationError: Error? //Der letzte  bekannte Fehler aufgerufen aus LocationManager
    
    /// Timer ist weak?, damit wir checken können, ob es mit == nil am laufen ist oder nicht. isValid funktioniert nicht.
    weak var getCurrentAdressOfUserTimer: Timer?
    
}
