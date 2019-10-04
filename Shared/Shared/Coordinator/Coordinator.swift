//
//  Coordinator.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 01/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
public protocol Coordinator: class {
    var childCoordinators: [Coordinator] {get set}
    
    func start()
}
extension Coordinator {
    
    public func store(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    public func free(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
