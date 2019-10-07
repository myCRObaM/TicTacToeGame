//
//  AppCoordinator.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 04/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import Shared
import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let presenter: UINavigationController
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.presenter = UINavigationController()
    }
    
    func start() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        
        let mainViewCoordinator = MainViewCoordinator(navController: presenter)
               //presenter.navigationBar.isHidden = true
               mainViewCoordinator.start()
    }

}
