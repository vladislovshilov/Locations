//
//  ViewController.swift
//  Locations
//
//  Created by Vladislav Shilov on 9/9/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    let center = UNUserNotificationCenter.current()
    
    var lastLocation: CLLocation?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager = LocationService.shared.locationManager
        LocationService.shared.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        
        mapView.setCenter(.init(latitude: 37.40957784, longitude: -122.19578850), animated: false)
        
        locationManager.monitoredRegions.forEach { region in
            if let circleRegion = region as? CLCircularRegion {
                addRegionOverlay(with: circleRegion.identifier, center: circleRegion.center, radius: circleRegion.radius)
            }
        }
        
        PersistanceService.shared.loadLocations()?.forEach({ location in
            addPin(on: .init(latitude: location.latitude, longitude: location.longitude), identifier: location.tag ?? "" + " \(location.time)")
        })
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in }
    }
    
    
    
    func addRegionOverlay(with name: String, center: CLLocationCoordinate2D, radius: Double) {
        mapView.addOverlay(Region(filename: name, center: center, radius: radius))
    }
    
    func addPin(on coordinates: CLLocationCoordinate2D, identifier: String) {
        let annotation = MKPointAnnotation()
        annotation.title = identifier
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    func showNotification(from location: CLLocation) {
        // 1
        let content = UNMutableNotificationContent()
        content.title = "New Location Update 📌"
        content.body = location.description
        content.sound = .default
        
        // 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(location.timestamp)", content: content, trigger: trigger)
        
        // 3
        center.add(request, withCompletionHandler: nil)
    }
    
    @IBAction func buttonDidPress(_ sender: Any) {
        LocationService.shared.startReceivingSignificantLocationChanges()
//        guard let coordinates = mapView.userLocation.location?.coordinate else { return }
//        let numberOfRegions = locationManager.monitoredRegions.count
//        monitorRegionAtLocation(center: coordinates, identifier: "region_\(numberOfRegions)")
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let region = overlay as? Region {
            let circleView = MKCircleRenderer(overlay: region)
            circleView.strokeColor = region.color
            return circleView
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
}

extension ViewController: LocationServiceDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        addPin(on: locations.last!.coordinate, identifier: "\(locations.last!.distance(from: lastLocation ?? locations.last!)) meters")
        lastLocation = locations.last
        showNotification(from: locations.last!)
        PersistanceService.shared.insertLocation(locations.last!, tag: "online")
    }
}

extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.last!)
//        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
//        addPin(on: locations.last!.coordinate, identifier: "\(locations.last!.distance(from: lastLocation ?? locations.last!)) meters")
//        lastLocation = locations.last
//        showNotification(from: locations.last!)
//        PersistanceService.shared.insertLocation(locations.last!, tag: "online")
//    }
//    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoring \(region)")
        if let region = region as? CLCircularRegion {
            addRegionOverlay(with: region.identifier, center: region.center, radius: region.radius)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("did enter to \(identifier)")
            print("enter on location: \(manager.location?.coordinate)")
            addPin(on: manager.location!.coordinate, identifier: "Enter on :\(identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("did exit from \(identifier)")
            print("exit on location: \(manager.location?.coordinate)")
            addPin(on: manager.location!.coordinate, identifier: "Exit from :\(identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("did fail monitoring got \(identifier)")
            print("error: \(error)")
        }
    }
}

class Region: MKCircle {
    var name: String?
    var color: UIColor?
    
    convenience init(filename: String, center: CLLocationCoordinate2D, radius: Double) {
        self.init(center: center, radius: radius)
        self.name = filename
        self.color = UIColor.red.withAlphaComponent(0.5)
    }
}
