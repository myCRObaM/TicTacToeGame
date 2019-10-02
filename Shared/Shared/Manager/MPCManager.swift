//
//  mpcManager.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 01/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import MultipeerConnectivity


public class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    //MARK: MPC functions
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
          print("Connected: \(peerID.displayName)")
          self.browser.stopBrowsingForPeers()
          self.peerControlDelegate?.connectionSucceded()
        case .connecting:
          print("Connecting: \(peerID.displayName)")
        case .notConnected:
          print("Disconnected: \(peerID.displayName)")
        @unknown default:
          print("fatal error")
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            print(message)
        self.peerControlDelegate?.didGetMessage(message: message)
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
          print("%@", "didReceiveInvitationFromPeer \(peerID)")
            self.invitationHandler = invitationHandler
        invitationHandler(true, session)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peerControlDelegate?.addPeer(name: peerID)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peerControlDelegate?.removePeer(name: peerID)
    }
    //MARK: Variables
    var peerID: MCPeerID
    var session: MCSession
    let advetiser : MCNearbyServiceAdvertiser
    let browser : MCNearbyServiceBrowser
    
    public weak var peerControlDelegate: PeerHandle?
    
    private let serviceType = "test"
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    //MARK: Init
    override public init() {
         peerID = MCPeerID(displayName: UIDevice.current.name)
               session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
               advetiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
               browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
               super.init()
               advetiser.delegate = self
               browser.delegate = self
               session.delegate = self
    }
    
    
    
}
extension MPCManager: VcToManagerDelegate {
    public func messageSent(message: String) {
        let messageToSend = "\(peerID.displayName): \(message)\n"
           let message = messageToSend.data(using: String.Encoding.utf8, allowLossyConversion: false)
           
           do {
             try self.session.send(message!, toPeers: self.session.connectedPeers, with: .unreliable)
            peerControlDelegate?.sendMessage(message: messageToSend)
           }
           catch {
             print("Error sending message")
           }
    }
    
    public func peerSelected(peer: MCPeerID) {
        browser.invitePeer(peer, to: session, withContext: Data(count: 1), timeout: 2)
    }
    
    public func joinButtonPressed() {
        self.browser.startBrowsingForPeers()
    }
    
    public func hostButtonPressed() {
        self.advetiser.startAdvertisingPeer()
    }
}
