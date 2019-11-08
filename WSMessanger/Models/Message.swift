//
//  Message.swift
//  WSMessanger
//
//  Created by TTgo on 01/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import MessageKit
import Firebase
import FirebaseFirestore

struct Message: MessageType {
    
    var id: String = ""
    var sender: SenderType {
        return user
    }
    var content: String = ""
    var txState: String = ""
    var sequence: String = ""
    var sentDate: Date
    var kind: MessageKind = .text("")   // text, ...
    var user: User
    var messageId: String {
        return id
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
//    private init(kind: MessageKind, user: User, messageId: String) {
//        self.kind = kind
//        self.user = user
//        self.messageId = messageId
//    }
    
    static func getDate() -> Date {
        return Date()
    }
    
    init(content: String, user: User, /*messageId: String,*/ kind: MessageKind, seq: String) {
        self.user = user
        self.content = content
//        self.messageId = messageId
        self.sentDate = Message.getDate()
        self.kind = kind
        self.txState = "true"
        self.sequence = seq
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        print("Data : \(data)")
//        let sentDate = data["created"] as? Date{
//             self.sentDate = sentDate
//         }
        guard let senderID = data["senderID"] as? String else { return nil }
        guard let senderName = data["senderName"] as? String else { return nil }
        if let state = data["txState"] as? String{
            txState = state
        }
        else{
            txState = "success"
        }
        
        if let seq = data["sequence"] as? String {
            sequence = seq
        }
        else{
            sequence = "0"
        }
        
        id = document.documentID
        user = User(senderId: senderID, displayName: senderName)
//        if let date = data["created"] as? Date {
//            sentDate = date
//        }
        
        let timestamp: Timestamp = data["created"] as! Timestamp
        sentDate = timestamp.dateValue()
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
        
        if let text = data["content"] as? String {
            self.kind = .text(text)
        }
        
    }
    
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "txState" : txState,
            "sequence" : sequence,
            "sentDate" : sentDate
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
        
    }
}
