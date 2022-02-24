//
//  AppDelegate.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 12.02.2022.
//

import UIKit
import Firebase
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "Raven")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().backgroundColor = UIColor(named: "PrimaryColor")
        UINavigationBar.appearance().barTintColor = UIColor(named: "PrimaryColor")
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().tintColor = UIColor(named: "AccentColor")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor")!]
        UINavigationBar.appearance().isTranslucent = false
        
        //firebase
        FirebaseApp.configure()
        
        //core data
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let videoGroupTableViewController = navigationController.topViewController as! VideoGroupTableViewController
        videoGroupTableViewController.dataController = dataController
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
}

