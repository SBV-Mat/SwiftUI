//
//  RoutesDataController.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//

import SwiftUI
import CoreData

class RoutesDataController: ObservableObject {
    let container = NSPersistentContainer(name: "RoutesDataModel")
        
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                return
            }
            
            print(description)
        }
    }
}
