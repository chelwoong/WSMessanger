//
//  ChannelCell.swift
//  WSMessanger
//
//  Created by TTgo on 14/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    //var cellButton: UIButton!
    var cellLabelLastDate: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var cellLabelTitle: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var cellLabelMessage: UILabel = {
        let label = UILabel()
        return label
    }()
    
    
    var cellLabelRead: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //cellLabelLastDate.frame = CGRect(x:35, y:40, width:300.0, height:40)
        cellLabelLastDate.textColor = UIColor.black
        //cellLabelMessage.backgroundColor = UIColor.blue
        cellLabelLastDate.font = cellLabelTitle.font.withSize(12)
        cellLabelLastDate.textAlignment = .right
        
        //cellCancelButton.frame = CGRect(x:x,y:0,width:20,height:20)
        cellLabelTitle.frame = CGRect(x:20, y:7, width:300.0, height:40)
        cellLabelTitle.textColor = UIColor.black
        //cellLabelTitle.backgroundColor = UIColor.red
        cellLabelTitle.font = cellLabelTitle.font.withSize(10)
        cellLabelTitle.font = UIFont.boldSystemFont(ofSize: cellLabelTitle.font.pointSize)
        
        print("label1 ---------------> : \(cellLabelTitle.frame)")
        
        cellLabelMessage.frame = CGRect(x:35, y:40, width:300.0, height:40)
        cellLabelMessage.textColor = UIColor.black
        //cellLabelMessage.backgroundColor = UIColor.blue
        cellLabelTitle.font = cellLabelTitle.font.withSize(20)
        
        cellLabelRead.textColor = UIColor.red
        //cellLabelMessage.backgroundColor = UIColor.blue
        cellLabelRead.font = cellLabelTitle.font.withSize(15)
        cellLabelRead.textAlignment = .right
        //cellLabelRead.font = UIFont.boldSystemFont(ofSize: cellLabelTitle.font.pointSize)
        
        addSubview(cellLabelLastDate)
        addSubview(cellLabelTitle)
        addSubview(cellLabelMessage)
        addSubview(cellLabelRead)
        //addSubview(cellButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    //   super.init(style: style, reuseIdentifier: reuseIdentifier)
    //}
}
