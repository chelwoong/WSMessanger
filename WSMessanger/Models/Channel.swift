//
//  Channel.swift
//  WSMessanger
//
//  Created by TTgo on 02/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Channel {
    
    var lastDate: String
    var lastMsg: String
    var id: String?
    var myNumber: String
    var peerNumber: String
    var peerName: String
    var name: String
    var read: String
    
    var dictionary: [String: Any] {
        
        var dic: [String:Any] = {
            return [
            "lastDate" : self.lastDate,
            "lastMsg" : self.lastMsg,
            "myNumber" : self.myNumber,
            "peerNumber" : self.peerNumber,
            "peerName" : self.peerName,
            "name" : self.name,
            "read" : self.read
            ]
        }()
        
        if let id = self.id {
            dic["id"] = id
        }
        
        return dic
    }
    
    
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
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        id = document.documentID
        print("\(id)")
        
        if let _name = data["name"] as? String { self.name = _name } else { self.name = "" }
        if let _myNumber = data["myNumber"] as? String { self.myNumber = _myNumber } else { self.myNumber = ""}
        if let _peerNumber = data["peerNumber"] as? String { self.peerNumber = _peerNumber } else { self.peerNumber = "" }
        if let _peerName = data["peerName"] as? String { self.peerName = _peerName } else { self.peerName = "" }
        if let _lastMsg = data["lastMsg"] as? String { self.lastMsg = _lastMsg } else { self.lastMsg = "" }
        if let _read = data["read"] as? String  { self.read = _read } else { self.read = "" }
        if let _lastDate = data["lastDate"] as? String { self.lastDate = _lastDate } else { self.lastDate = "" }
        if let _id = data["id"] as? String { self.id = _id } else { self.id = "" }
        
    }
}

extension Channel: Comparable {

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.name < rhs.name
    }
}
