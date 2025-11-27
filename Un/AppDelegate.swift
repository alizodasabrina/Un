//
//  AppDelegate.swift
//  Unpl
//
//  Created by Sabrina Mavlyanova on 21/11/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Глобальный массив для сохранения избранных фоток
    static var favoriteImages: [UnsplashImage] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}
