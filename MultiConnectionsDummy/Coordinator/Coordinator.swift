//
//  Coordinator.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 01/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
protocol Coordinator: class {
    var childCoordinators: [Coordinator] {get set}
    
    func start()
}
