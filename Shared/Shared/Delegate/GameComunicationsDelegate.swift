//
//  GameComunicationsDelegate.swift
//  Shared
//
//  Created by Matej Hetzel on 02/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation

public protocol GameToManager: class {
    func buttonPressed(location: (Int, Int))
    func didDissmiss(isHost: Bool)
}

public protocol ManagerToGame: class {
    func sendMessage(message: String, isHost: Bool, willPlay: Bool)
    func didGetMessage(message: String, isHost: Bool, willPlay: Bool)
}
