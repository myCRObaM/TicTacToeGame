//
//  MainScreenTest.swift
//  MultiConnectionsDummyTests
//
//  Created by Matej Hetzel on 07/10/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import Nimble
import Quick
import Cuckoo
import Shared
import MultipeerConnectivity

@testable import MultiConnectionsDummy

class MainScreenTest: QuickSpec {
    override func spec(){
        describe("prepare for test"){
            var mainScreenViewModel: MainScreenViewModel!
            var testScheduler: TestScheduler!
            let disposeBag = DisposeBag()
            context("initialise viewModel"){
                 var showClosingSubject: TestableObserver<Bool>!
                var tableViewControlSubject: TestableObserver<Bool>!
                beforeEach {
                    testScheduler = TestScheduler(initialClock: 0)
                    mainScreenViewModel = MainScreenViewModel(dependencies: MainScreenViewModel.Dependencies(mpcManager: MPCManager(), scheduler: testScheduler))
                    
                    
                    let input = MainScreenViewModel.Input(didSelectCellSubject: PublishSubject(), shouldShowClosingSubject: PublishSubject(), gameScreenControlSubject: PublishSubject(), addRemovePeersSubject: PublishSubject(), browserOpeningSubject: PublishSubject())
                           let output = mainScreenViewModel.transfrom(input: input)
                           
                           for disposable in output.disposables {
                               disposable.disposed(by: disposeBag)
                           }
                    
                    showClosingSubject = testScheduler.createObserver(Bool.self)
                    tableViewControlSubject = testScheduler.createObserver(Bool.self)
                    mainScreenViewModel.output.showClosingSubject.subscribe(showClosingSubject).disposed(by: disposeBag)
                    mainScreenViewModel.output.tableViewControlSubject.subscribe(tableViewControlSubject).disposed(by: disposeBag)
                }
                it("Closing popup function check"){
                    testScheduler.start()
                    mainScreenViewModel.input.shouldShowClosingSubject.onNext((false, true))
                    expect(showClosingSubject.events.count).toEventually(equal(1))
                }
                it("TableView Control Test"){
                    testScheduler.start()
                    mainScreenViewModel.input.addRemovePeersSubject.onNext((MCPeerID(displayName: "s"), true))
                    expect(tableViewControlSubject.events.count).toEventually(equal(1))
                    expect(tableViewControlSubject.events[0].value.element).toEventually(equal(false))
                    
                }
            }
            
        }
    }
}
