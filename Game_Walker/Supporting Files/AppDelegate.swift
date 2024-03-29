//
//  AppDelegate.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        //let db = Firestore.firestore()
        
        // IQKeyvoardManager resolves the problem that keyboard covers the screen
        // Let XCode to use the library
        IQKeyboardManager.shared.enable = true
        // Inserting a toolbar above the keyboard without additional lines of code
        IQKeyboardManager.shared.enableAutoToolbar = true
        // Touch anywhere outside the keyboard will hide the keyboard
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        return true
    }
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

