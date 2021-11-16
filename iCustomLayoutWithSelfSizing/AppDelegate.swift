//
//  AppDelegate.swift
//  iCustomLayoutWithSelfSizing
//
//  Created by BruceHuang on 2021/11/16.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CardListVC()
        window?.makeKeyAndVisible()
        
        return true
    }
}

