//
//  ViewController.swift
//  MultiConnectionsDummy
//
//  Created by Matej Hetzel on 30/09/2019.
//  Copyright © 2019 Matej Hetzel. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Shared
import GameModule
import RxSwift

public class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: TableView functions
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.peersList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "da") as? CustomTableViewCell {
            cell.backgroundColor = .clear
            cell.setupCell(letter: String(indexPath.row), location: viewModel.peersList[indexPath.row].displayName)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.input.didSelectCellSubject.onNext(indexPath.row)
    }
    
    //MARK: VARIABLES
    var serviceType = "ioscreator-chat"
    var viewModel: MainScreenViewModel!
    let disposeBag = DisposeBag()
    
    var messageToSend: String!
    
    
    let customView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "HomeImage")
        view.contentMode = .scaleToFill
        return view
    }()
    
    let searchButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.setTitle("New game", for: .normal)
        view.setTitleColor(.white, for: .normal)
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("error")
    }
    
    
    //MARK: viewDidLoad
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupView()
        setupMultipeer()
    }
    func setupViewModel(){
        let input = MainScreenViewModel.Input(didSelectCellSubject: PublishSubject(), shouldShowClosingSubject: PublishSubject(), gameScreenControlSubject: PublishSubject(), addRemovePeersSubject: PublishSubject(), browserOpeningSubject: PublishSubject())
        let output = viewModel.transfrom(input: input)
        
        for disposable in output.disposables {
            disposable.disposed(by: disposeBag)
        }
        
        self.dismissTicTacToeVC(subject: output.showClosingSubject).disposed(by: disposeBag)
        self.tableViewAfterPeerUpdate(subject: output.tableViewControlSubject).disposed(by: disposeBag)
    }
    //MARK: setupView
    func setupView(){
        self.navigationController?.navigationBar.isHidden = false
        view.addSubview(customView)
        view.addSubview(imageView)
        view.addSubview(searchButton)
        
        setupConstraints()
        searchButton.addTarget(self, action: #selector(showConnectionMenu), for: .touchUpInside)
    }
    
    //MARK: setupMultipeer
    func setupMultipeer(){
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "da")
    }
    
    //MARK: Setup Constraints
    func setupConstraints(){
        let viewsnp = view.snp
        customView.snp.makeConstraints { (make) in
            make.top.equalTo(viewsnp.top)
            make.bottom.equalTo(viewsnp.bottom)
            make.leading.equalTo(viewsnp.leading)
            make.trailing.equalTo(viewsnp.trailing)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(viewsnp.leading)
            make.trailing.equalTo(viewsnp.trailing)
            make.height.equalTo(UIScreen.main.bounds.height/3)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.height.equalTo(UIScreen.main.bounds.height/20)
            make.centerX.equalTo(viewsnp.centerX)
        }
    }
    
    //MARK: add TableView to subview
    func addTableViewToSubview(){
        view.addSubview(tableView)
        
        let snpview = view.snp
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchButton.snp.bottom).offset(20)
            make.bottom.equalTo(snpview.bottom)
            make.leading.equalTo(snpview.leading)
            make.trailing.equalTo(snpview.trailing)
        }
    }
    //MARK: Show Connection menu
    @objc func showConnectionMenu() {
        let ac = UIAlertController(title: "Connection Menu", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: hostSession))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func hostSession(action: UIAlertAction) {
        viewModel.input.browserOpeningSubject.onNext(false)
    }
    
    func joinSession(action: UIAlertAction) {
        viewModel.input.browserOpeningSubject.onNext(true)
    }
    
    //MARK: Dismiss
    func dismissTicTacToeVC(subject: PublishSubject<Bool>) -> Disposable{
        subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(viewModel.dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  bool in
                self.viewModel.input.gameScreenControlSubject.onNext((false, self, self.viewModel.dependencies.mpcManager, true, false, false))
                
                DispatchQueue.main.async { [unowned self] in
                    let alert = UIAlertController(title: "Closed", message: "Your friend left the game", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                }
            })
        
    }
    
    func tableViewAfterPeerUpdate(subject: PublishSubject<Bool>) -> Disposable{
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(viewModel.dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  bool in
                self.tableView.reloadData()
                switch bool {
                case true:
                    self.tableView.removeFromSuperview()
                case false:
                    self.addTableViewToSubview()
                    UIView.animate(withDuration: 1,
                                          delay: 0,
                                          options: [.curveEaseIn, .transitionCurlUp],
                                          animations: {
                                           self.view.layoutIfNeeded()
                           }) { (Bool) in
                           }
                }
            })
    }
    
}

extension MainScreenViewController: PeerHandle {
    
    public func didDisconnect(isHost: Bool) {
        viewModel.input.shouldShowClosingSubject.onNext((isHost, false))
    }
    
    public func openGame(willPlay: Bool, isHost: Bool) {
        viewModel.input.gameScreenControlSubject.onNext((true, self, viewModel.dependencies.mpcManager, willPlay, isHost, true))
    }
    
    public func connectionSucceded() {
        viewModel.input.addRemovePeersSubject.onNext((MCPeerID(displayName: "notUsed"), false))
    }
    
    public func addPeer(name: MCPeerID) {
        viewModel.input.addRemovePeersSubject.onNext((name, true))
    }
    
    public func removePeer(name: MCPeerID) {
        print("remove")
    }
}

