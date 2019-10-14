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
        
        let contentsnp = contentView.snp
        
        hostNumber.snp.makeConstraints { (make) in
            make.leading.equalTo(contentsnp.leading).offset(5)
            make.top.equalTo(contentsnp.top).offset(5)
            make.bottom.equalTo(contentsnp.bottom).offset(-5)
            make.width.equalTo(49)
        }
        
        hostNameLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(contentsnp.trailing)
            make.leading.equalTo(hostNumber.snp.trailing).offset(5)
            make.centerY.equalTo(hostNumber.snp.centerY)
        }
    }
    public func setupCell(letter: String, location: String){
        self.hostNumber.text = letter
        self.hostNameLabel.text = location
    }
}
