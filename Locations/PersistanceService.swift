//
//  PersistanceService.swift
//  Locations
//
//  Created by Vladislav Shilov on 9/11/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import CoreData
import CoreLocation

class PersistanceService {
    static let shared = PersistanceService()
    
    let persistanceContainer = NSPersistentContainer(name: "Model")
    
    var locations: [Location]?
    
    init() {
        persistanceContainer.loadPersistentStores { desc, error in
            print("load error: \(error)")
        }
    }
    
    func insertLocation(_ location: CLLocation, tag: String) {
        let context = persistanceContainer.viewContext
        let item = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context) as! Location
        item.tag = tag
        item.time = location.timestamp
        item.longitude = location.coordinate.longitude
        item.latitude = location.coordinate.latitude
        
        try! context.save()
    }
    
    func loadLocations() -> [Location]? {
        let context = persistanceContainer.viewContext
        let itemsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        locations = try? context.fetch(itemsFetchRequest) as? [Location]
        return locations
    }
    
    func removeLocations() {
        let context = persistanceContainer.viewContext
        locations?.forEach({ location in
            context.delete(location)
        })
        
        try? context.save()
    }
}
