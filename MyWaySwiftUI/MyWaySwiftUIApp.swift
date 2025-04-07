//
//  MyWaySwiftUIApp.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 19.03.2025.
//

import SwiftUI
import CoreLocation

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        
        return true
    }
}

@main
struct MyWaySwiftUIApp: App {
    @StateObject private var routesDataController = RoutesDataController()
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, routesDataController.container.viewContext)
        }
    }
}
