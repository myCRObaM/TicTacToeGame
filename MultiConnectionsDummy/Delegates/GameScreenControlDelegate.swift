//
//  GameOpeningDelegate.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 04/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import Shared

protocol GameScreenControlDelegate: class {
    func openGame(presenter: MainScreenViewController, manager: MPCManager, willPlay: Bool)
    func closeGame()
}
