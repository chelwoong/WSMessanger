//
//  Channel.swift
//  WSMessanger
//
//  Created by TTgo on 02/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import Foundation

struct Channel {
    
    var lastDate: String
    var lastMsg: String
    let id: String?
    var myNumber: String
    var peerNumber: String
    var peerName: String
    var name: String
    var read: String
    
    init(name: String, peerName: String, myNumber: String, peerNumber: String) {
        self.id = ""
        self.name = name
        self.myNumber = myNumber
        self.peerNumber = peerNumber
        if peerNumber == "" {
            self.peerName = peerNumber
        }
        else {
            self.peerName = peerName
        }
        
        self.lastDate = Date().description
        self.read = "true"
        self.lastMsg = ""
    }
    
    
    
}
