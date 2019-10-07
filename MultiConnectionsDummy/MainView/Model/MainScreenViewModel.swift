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
    struct Input {
        var didSelectCellSubject: PublishSubject<Int>
        var shouldShowClosingSubject: PublishSubject<Bool>
        var gameScreenControlSubject: PublishSubject<(Bool, MainScreenViewController, MPCManager, Bool, Bool)>
        var addRemovePeersSubject: PublishSubject<(String, Bool)>
    }
    
    struct Output {
        var showClosingSubject: PublishSubject<Bool>
        var disposables: [Disposable]
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
        disposables.append(controlPeers(subject: PublishSubject<(MCPeerID, Bool)>()))
        
        self.output = Output(showClosingSubject: PublishSubject<Bool>(), disposables: disposables)
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
    
    func selectedCell(subject: PublishSubject<Int>) -> Disposable{
        return subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  bool in
                self.vcToManagerButton?.peerSelected(peer: self.peersList[bool])
            })
    }
    
    func shouldShowClosingPopUp(subject: PublishSubject<Bool>) -> Disposable{
        return subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  bool in
                if !bool {
                    self.output.showClosingSubject.onNext(true)
                }
            })
    }
    
    func controlGameScreen(subject: PublishSubject<(Bool, MainScreenViewController, MPCManager, Bool, Bool)>) -> Disposable {
        return subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: {  (bool, vc, manager, wp, isHost) in
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
    
    func controlPeers(subject: PublishSubject<(MCPeerID, Bool)>) -> Disposable {
        return subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependencies.scheduler)
            .subscribe(onNext: { [unowned self]  (name, bool) in
                switch bool {
                case true:
                    self.peersList.append(name)
                case false:
                    self.peersList.removeAll()
                }
               
            })
    }
    
}
