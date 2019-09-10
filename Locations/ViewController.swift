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

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        
        mapView.setCenter(.init(latitude: 37.40957784, longitude: -122.19578850), animated: false)
        
        locationManager.monitoredRegions.forEach { region in
            if let circleRegion = region as? CLCircularRegion {
                addRegionOverlay(with: circleRegion.identifier, center: circleRegion.center, radius: circleRegion.radius)
            }
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
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
    
    func addRegionOverlay(with name: String, center: CLLocationCoordinate2D, radius: Double) {
        mapView.addOverlay(Region(filename: name, center: center, radius: radius))
    }
    
    func addPin(on coordinates: CLLocationCoordinate2D, identifier: String) {
        let annotation = MKPointAnnotation()
        annotation.title = identifier
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func buttonDidPress(_ sender: Any) {
        guard let coordinates = mapView.userLocation.location?.coordinate else { return }
        let numberOfRegions = locationManager.monitoredRegions.count
        monitorRegionAtLocation(center: coordinates, identifier: "region_\(numberOfRegions)")
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

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
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
