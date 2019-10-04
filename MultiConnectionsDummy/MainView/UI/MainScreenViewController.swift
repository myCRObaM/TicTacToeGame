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
    weak var vcToManagerButton: VcToManagerDelegate?
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
    
    //MARK: viewDidLoad
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupViewModel()
        setupView()
        setupMultipeer()
    }
    func setupViewModel(){
        let mPCManager = MPCManager()
        mPCManager.peerControlDelegate = self
        self.vcToManagerButton = mPCManager
        viewModel = MainScreenViewModel(dependencies: MainScreenViewModel.Dependencies(mpcManager: mPCManager, scheduler: ConcurrentDispatchQueueScheduler(qos: .background)))
        viewModel.vcToManagerButton = vcToManagerButton
        
        let input = MainScreenViewModel.Input(didSelectCellSubject: PublishSubject<Int>(), shouldShowClosingSubject: PublishSubject<Bool>(), gameScreenControlSubject: PublishSubject<(Bool, MainScreenViewController, MPCManager, Bool, Bool)>())
        let output = viewModel.transfrom(input: input)
        
        for disposable in output.disposables {
            disposable.disposed(by: disposeBag)
        }
        
        self.dismissTicTacToeVC(subject: output.showClosingSubject).disposed(by: disposeBag)
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
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/3),
            
            
            searchButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            searchButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
        
    }
    
    //MARK: add TableView to subview
    func addTableViewToSubview(){
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
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
        vcToManagerButton?.hostButtonPressed()
    }
    
    func joinSession(action: UIAlertAction) {
        vcToManagerButton?.joinButtonPressed()
    }
    
    //MARK: Dismiss
    func dismissTicTacToeVC(subject: PublishSubject<Bool>) -> Disposable{
        subject
            .observeOn(MainScheduler.instance)
            .subscribeOn(viewModel.dependencies.scheduler)
            .subscribe(onNext: {[unowned self]  bool in
                self.viewModel.input.gameScreenControlSubject.onNext((false, self, self.viewModel.dependencies.mpcManager, true, false))
                
                DispatchQueue.main.async { [unowned self] in
                    let alert = UIAlertController(title: "Closed", message: "Your friend left the game", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                }
            })
        
    }
    
}

extension MainScreenViewController: PeerHandle {
    
    public func didDisconnect(isHost: Bool) {
        viewModel.input.shouldShowClosingSubject.onNext(isHost)
        viewModel.isConnected = false
    }
    
    public func openGame(willPlay: Bool, isHost: Bool) {
        self.viewModel.isConnected = true
        viewModel.input.gameScreenControlSubject.onNext((true, self, viewModel.dependencies.mpcManager, willPlay, isHost))
    }
    
    public func connectionSucceded() {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.peersList.removeAll()
            self.tableView.reloadData()
            self.tableView.removeFromSuperview()
            self.vcToManagerButton?.didConnect()
        }
        
    }
    
    public func addPeer(name: MCPeerID) {
        
        self.viewModel.peersList.append(name)
        tableView.reloadData()
        self.addTableViewToSubview()
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseIn, .transitionCurlUp],
                       animations: {
                        self.view.layoutIfNeeded()
        }) { (Bool) in
        }
        
    }
    
    public func removePeer(name: MCPeerID) {
        print("remove")
    }
}

