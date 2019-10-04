//
//  Coordinator.swift
//  Shared
//
//  Created by Matej Hetzel on 04/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
public protocol ParentCoordinatorDelegate {
    func childHasFinished(coordinator: Coordinator)
}

public protocol CoordinatorDelegate: class {
    func viewControllerHasFinished()
}
