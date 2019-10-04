//
//  TableViewCell.swift
//  Shared
//
//  Created by Josip Marković on 25/09/2019.
//  Copyright © 2019 Josip Marković. All rights reserved.
//

import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell {
    
    let hostNumber: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 182/255, green: 222/255, blue: 238/255, alpha: 1)
        view.textColor = .black
        view.font = UIFont(name: "GothamRounded-Light", size: 40)
        view.text = "L"
        view.textAlignment = .center
        view.numberOfLines = 1
        return view
    }()
    let hostNameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.textColor = .black
        view.text = "ASDFAFSDASDASDASDAS"
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        contentView.addSubview(hostNumber)
        contentView.addSubview(hostNameLabel)
        
        NSLayoutConstraint.activate([
            hostNumber.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            hostNumber.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            hostNumber.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            hostNumber.widthAnchor.constraint(equalToConstant: 49),
            
            hostNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostNameLabel.leadingAnchor.constraint(equalTo: hostNumber.trailingAnchor, constant: 5),
            hostNameLabel.centerYAnchor.constraint(equalTo: hostNumber.centerYAnchor)
        ])
    }
    public func setupCell(letter: String, location: String){
        self.hostNumber.text = letter
        self.hostNameLabel.text = location
    }
}
