//
//  AppDelegate.swift
//  Locations
//
//  Created by Vladislav Shilov on 9/9/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let userDefaults = UserDefaults.standard
        
        if let _ = launchOptions?[UIApplication.LaunchOptionsKey.location] {
            let locationManager = LocationService.shared.locationManager
            
            if let location = locationManager.location {
                PersistanceService.shared.insertLocation(location, tag: "offline")
            }
            
            LocationService.shared.startReceivingSignificantLocationChanges()
            
            userDefaults.set(true, forKey: "launched_location")
            
            let content = UNMutableNotificationContent()
            content.title = "New Location Update 📌"
            content.body = locationManager.location?.description ?? ""
            content.sound = .default
            
            // 2
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "\(locationManager.location?.timestamp ?? Date())", content: content, trigger: trigger)
            
            // 3
            center.add(request, withCompletionHandler: nil)
        }
        else {
            print(userDefaults.value(forKey: "launched_location"))
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
