//
//  AppDelegate.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 30/09/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import UIKit
import RxSwift
import Shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        //guard let window = self.window else { fatalError("No Window") }
        let appCoordinator = AppCoordinator(window: window!)
        
        appCoordinator.start()
        return true
    }

}

