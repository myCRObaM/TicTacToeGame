//
//  CommunicationsDelegate.swift
//  Shared
//
//  Created by Matej Hetzel on 02/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol PeerHandle: class{
    func addPeer(name: MCPeerID)
    func removePeer(name: MCPeerID)
    func connectionSucceded()
    func openGame(willPlay: Bool)
    func didDisconnect(isHost: Bool)
}

public protocol VcToManagerDelegate: class {
    func joinButtonPressed()
    func hostButtonPressed()
    func peerSelected(peer: MCPeerID)
    func didConnect()
}
