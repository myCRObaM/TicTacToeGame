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
    
    let letterLabel: UILabel = {
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
    #warning("host name")
    let locationLabel: UILabel = {
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
        contentView.addSubview(letterLabel)
        contentView.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            letterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            letterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            letterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            letterLabel.widthAnchor.constraint(equalToConstant: 49),
            
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: letterLabel.trailingAnchor, constant: 5),
            locationLabel.centerYAnchor.constraint(equalTo: letterLabel.centerYAnchor)
        ])
    }
    public func setupCell(letter: String, location: String){
        self.letterLabel.text = letter
        self.locationLabel.text = location
    }
}
