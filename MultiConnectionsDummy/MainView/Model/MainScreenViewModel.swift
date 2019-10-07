//
//  MainViewModel.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 01/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import GameModule
import Shared
import RxSwift

public class MainScreenViewModel {
    //MARK: Define structs
    struct Input {
        var didSelectCellSubject: PublishSubject<Int>
        var shouldShowClosingSubject: PublishSubject<(Bool, Bool)>
        var gameScreenControlSubject: PublishSubject<(Bool, MainScreenViewController, MPCManager, Bool, Bool, Bool)>
        var addRemovePeersSubject: PublishSubject<(MCPeerID, Bool)>
        var browserOpeningSubject: PublishSubject<Bool>
    }
    
    struct Output {
        var showClosingSubject: PublishSubject<Bool>
        var disposables: [Disposable]
        var tableViewControlSubject: PublishSubject<Bool>
    }
    
    struct Dependencies {
        let mpcManager: MPCManager
        var scheduler: SchedulerType
    }
    
    //MARK: Transform
    func transfrom(input: MainScreenViewModel.Input) -> MainScreenViewModel.Output {
        self.input = input
        var disposables = [Disposable]()
        
        disposables.append(selectedCell(subject: input.didSelectCellSubject))
        disposables.append(shouldShowClosingPopUp(subject: input.shouldShowClosingSubject))
        disposables.append(controlGameScreen(subject: input.gameScreenControlSubject))
        disposables.append(controlPeers(subject: input.addRemovePeersSubject))
        disposables.append(browserControl(subject: input.browserOpeningSubject))
        
        self.output = Output(showClosingSubject: PublishSubject<Bool>(), disposables: disposables, tableViewControlSubject: PublishSubject())
        return output
        
    }
    
    //MARK: Variables
    var peersList = [MCPeerID]()
    var input: Input!
    var output: Output!
    let dependencies: Dependencies
    var isConnected: Bool = false
    weak var vcToManagerButton: VcToManagerDelegate?
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    //MARK: cell
    func selectedCell(subject: PublishSubject<Int>) -> Disposable{
        return subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  bool in
                self.vcToManagerButton?.peerSelected(peer: self.peersList[bool])
            })
    }
    //MARK: Closing popup
    func shouldShowClosingPopUp(subject: PublishSubject<(Bool, Bool)>) -> Disposable{
        return subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  (bool, isConn) in
                self.isConnected = isConn
                if !bool {
                    self.output.showClosingSubject.onNext(true)
                }
            })
    }
    //MARK: Game Screen control
    func controlGameScreen(subject: PublishSubject<(Bool, MainScreenViewController, MPCManager, Bool, Bool, Bool)>) -> Disposable {
        return subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: {  [unowned self] (bool, vc, manager, wp, isHost, isConn) in
                self.isConnected = isConn
                if bool {
                    let gameCoordinator = GameScreenCoordinator(presenter: vc, manager: manager, willPlay: wp, isHost: isHost)
                    gameCoordinator.start()
                }
                else {
                    vc.dismiss(animated: true) {
                    }
                }
            })
    }
    //MARK: Peer control
    func controlPeers(subject: PublishSubject<(MCPeerID, Bool)>) -> Disposable {
        return subject
        .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: { [unowned self]  (name, bool) in
                switch bool {
                case true:
                    self.peersList.append(name)
                    self.output.tableViewControlSubject.onNext(false)
                case false:
                    self.peersList.removeAll()
                    self.vcToManagerButton?.didConnect()
                    self.output.tableViewControlSubject.onNext(true)
                }
               
            })
    }
    //MARK: Browser control
    func browserControl(subject: PublishSubject<Bool>) -> Disposable {
        return subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependencies.scheduler)
        .subscribe(onNext: {  [unowned self] bool in
            switch bool {
            case true:
                self.vcToManagerButton?.joinButtonPressed()
            case false:
                self.vcToManagerButton?.hostButtonPressed()
            }
            })
    }
    
}
