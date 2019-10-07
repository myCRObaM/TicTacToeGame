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
    let presenter: UINavigationController
    
    public init(navController: UINavigationController) {
        let manager = MPCManager()
        self.presenter = navController
        let viewModel = MainScreenViewModel(dependencies: MainScreenViewModel.Dependencies(mpcManager: manager, scheduler: ConcurrentDispatchQueueScheduler(qos: .background)))
        viewModel.vcToManagerButton = manager
        viewController = MainScreenViewController(viewModel: viewModel)
        manager.peerControlDelegate = viewController
    }
    
    public func start() {
        presenter.pushViewController(viewController, animated: true)
        print("added viewController")
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
