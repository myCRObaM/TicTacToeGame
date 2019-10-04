//
//  MainViewCoordinator.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 01/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import Shared
import UIKit

class MainViewCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    func start() {
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
    }
    
    
}
