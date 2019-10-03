//
//  MainViewModel.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 01/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Shared

class MainViewModel {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    struct Dependencies {
        let mpcManager: MPCManager
    }
    var peersList = [MCPeerID]()
    let dependencies: Dependencies
    var isConnected: Bool = false
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
