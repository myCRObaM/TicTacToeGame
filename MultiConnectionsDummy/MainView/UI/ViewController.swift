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

public class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        vcToManagerButton?.peerSelected(peer: viewModel.peersList[indexPath.row])
    }
    
    //MARK: VARIABLES
    var serviceType = "ioscreator-chat"
    var viewModel: MainViewModel!
    weak var vcToManagerButton: VcToManagerDelegate?
    var gameCoordinator: GameScreenCoordinator!
    
    var messageToSend: String!
    
    
    let cview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let chatView: UIImageView = {
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
        let mPCManager = MPCManager()
        mPCManager.peerControlDelegate = self
        self.vcToManagerButton = mPCManager
        viewModel = MainViewModel(dependencies: MainViewModel.Dependencies(mpcManager: mPCManager))
        setupView()
        setupMultipeer()
    }
    
    //MARK: setupView
    func setupView(){
        self.navigationController?.navigationBar.isHidden = false
        view.addSubview(cview)
        view.addSubview(chatView)
        view.addSubview(searchButton)
        
        setupConstraints()
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
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
        setupChatView(height: UIScreen.main.bounds.height/4)
        NSLayoutConstraint.activate([
            cview.topAnchor.constraint(equalTo: view.topAnchor),
            cview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            
            searchButton.topAnchor.constraint(equalTo: chatView.bottomAnchor, constant: 20),
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
    
    //MARK: SetupChatView
    func setupChatView(height: CGFloat){
        for constraint in chatView.constraints {
            chatView.removeConstraint(constraint)
        }
        NSLayoutConstraint.activate([
                      self.chatView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                      self.chatView.leadingAnchor.constraint(equalTo: self.cview.leadingAnchor),
                      self.chatView.trailingAnchor.constraint(equalTo: self.cview.trailingAnchor),
                      self.chatView.heightAnchor.constraint(equalToConstant: height),
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
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            let isKeyboardShown = notification.name == UIResponder.keyboardWillShowNotification
            let height = isKeyboardShown ? -keyboardHeight : -60
            
            self.setupChatView(height: UIScreen.main.bounds.height / 2 + height/4)
            
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func openNewViewController(willPlay: Bool){
        gameCoordinator = GameScreenCoordinator(presenter: self, manager: viewModel.dependencies.mpcManager, willPlay: willPlay)
        gameCoordinator.start()
    }
    
    func dismissTicTacToeVC(isHost: Bool){
        gameCoordinator.dismissVC()
        if !isHost {
            DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController(title: "Closed", message: "Your friend left the game", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                       alert.dismiss(animated: true, completion: nil)
                   }))
                   self.present(alert, animated: true)
            }
        }
    }
    
}

extension ViewController: PeerHandle {
    public func didDisconnect(isHost: Bool) {
        dismissTicTacToeVC(isHost: isHost)
        viewModel.isConnected = false
    }
    
    public func openGame(willPlay: Bool) {
        self.viewModel.isConnected = true
        self.openNewViewController(willPlay: willPlay)
    }
    
    public func connectionSucceded() {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.peersList.removeAll()
            self.tableView.reloadData()
            self.tableView.removeFromSuperview()
            self.setupChatView(height: UIScreen.main.bounds.height/4)
            self.vcToManagerButton?.didConnect()
        }
        
    }
    
    public func addPeer(name: MCPeerID) {
        
        self.viewModel.peersList.append(name)
        tableView.reloadData()
        self.addTableViewToSubview()
        self.setupChatView(height: UIScreen.main.bounds.height/4)
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

