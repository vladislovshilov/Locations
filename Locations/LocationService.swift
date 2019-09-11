//
//  LocationService.swift
//  Locations
//
//  Created by Vladislav Shilov on 9/11/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import CoreLocation

protocol LocationServiceDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
}

class LocationService: NSObject {
    static let shared = LocationService()
    
    let locationManager = CLLocationManager()
    
    var delegate: LocationServiceDelegate?
    
    func startReceivingSignificantLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The service is not available.
            return
        }
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the app is authorized.
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            // Make sure region monitoring is supported.
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                // Register the region.
                let maxDistance = min(5.0, locationManager.maximumRegionMonitoringDistance)
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                locationManager.startMonitoring(for: region)
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        PersistanceService.shared.insertLocation(locations.last!, tag: "online")
        delegate?.locationManager(manager, didUpdateLocations: locations)
    }
}
