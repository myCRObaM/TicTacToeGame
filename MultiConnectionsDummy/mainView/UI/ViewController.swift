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

protocol VcToManagerDelegate: class {
    func joinButtonPressed()
    func hostButtonPressed()
    func peerSelected(peer: MCPeerID)
    func messageSent(message: String)
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.peersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "da") as? CustomTableViewCell {
            cell.backgroundColor = .clear
            cell.setupCell(letter: String(indexPath.row), location: viewModel.peersList[indexPath.row].displayName)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vcToManagerButton?.peerSelected(peer: viewModel.peersList[indexPath.row])
    }
    
    //MARK: VARIABLES
    var serviceType = "ioscreator-chat"
    var viewModel: MainViewModel!
    weak var vcToManagerButton: VcToManagerDelegate?
    
    var messageToSend: String!
    
    
    let cview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let chatView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = true
        view.isEditable = false
        return view
    }()
    
    let chatWrite: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    let sendButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .magenta
        view.setTitle("Send", for: .normal)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    let searchButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.setTitle("Manage Sessions", for: .normal)
        view.setTitleColor(.magenta, for: .normal)
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
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
        view.addSubview(chatWrite)
        view.addSubview(sendButton)
        view.addSubview(searchButton)
        
        chatView.text = "Ovo je test ChatViewa\n"
        
        setupConstraints()
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        searchButton.addTarget(self, action: #selector(showConnectionMenu), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
    }
    
    //MARK: setupMultipeer
    func setupMultipeer(){
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "da")
    }
    
    //MARK: Setup Constraints
    func setupConstraints(){
        setupChatView(height: UIScreen.main.bounds.height/1.5)
        NSLayoutConstraint.activate([
            cview.topAnchor.constraint(equalTo: view.topAnchor),
            cview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            chatWrite.topAnchor.constraint(equalTo: chatView.bottomAnchor, constant: 5),
            chatWrite.leadingAnchor.constraint(equalTo: cview.leadingAnchor),
            chatWrite.trailingAnchor.constraint(equalTo: cview.trailingAnchor),
            
            sendButton.topAnchor.constraint(equalTo: chatWrite.bottomAnchor, constant: 20),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            searchButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            searchButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/20),
            
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
    
    @objc func sendButtonPressed(){
        vcToManagerButton?.messageSent(message: chatWrite.text ?? "")
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
    
}

extension ViewController: PeerHandle {
    func connectionSucceded() {
        DispatchQueue.main.async { [unowned self] in
            self.viewModel.peersList.removeAll()
            self.tableView.reloadData()
            self.tableView.removeFromSuperview()
            self.setupChatView(height: UIScreen.main.bounds.height/1.5)
               }
         
        
    }
    
    
    func didGetMessage(message: String) {
        DispatchQueue.main.async { [unowned self] in
            self.chatView.text = self.chatView.text + message
        }
    }
    
    func sendMessage(message: String) {
        chatView.text = chatView.text + message
        chatWrite.text = ""
    }
    
    func addPeer(name: MCPeerID) {
        
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
    
    func removePeer(name: MCPeerID) {
        print("remove")
    }
}

