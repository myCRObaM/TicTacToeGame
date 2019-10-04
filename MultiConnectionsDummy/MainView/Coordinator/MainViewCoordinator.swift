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
import RxSwift
import GameModule

public class MainViewCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []
    var viewController: MainScreenViewController!
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    public func start() {
        viewController = MainScreenViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    deinit {
        print("deinit")
    }
    
    
}

extension MainViewCoordinator: GameScreenControlDelegate {
    func openGame(presenter: MainScreenViewController, manager: MPCManager, willPlay: Bool) {
        let gameCoordinator = GameScreenCoordinator(presenter: presenter, manager: manager, willPlay: willPlay, isHost: true)
        gameCoordinator.store(coordinator: gameCoordinator)
        gameCoordinator.start()
    }
    
    func closeGame() {
        viewController.dismiss(animated: true) {
        }
    }
    
}
