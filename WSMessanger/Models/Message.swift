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
import RealmSwift

class Message: Object, MessageType {
    
    @objc dynamic var id: String = ""
    @objc dynamic var senderID: String = ""
    @objc dynamic var content: String = ""
//    @objc dynamic var created: Date = Date()
    @objc dynamic var txState: String = ""
    @objc dynamic var sequence: String = ""
    @objc dynamic var senderName: String = ""
    
    @objc dynamic var sentDate: Date = Date()
    var sender: SenderType {
        get {
            return user
        }
    }
    
    
    var kind: MessageKind = .text("")   // text, ...
    var user: User = User(senderId: "", displayName: "")
    var messageId: String {
        get {
            return id
        }
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
    
    convenience init(content: String, user: User, /*messageId: String,*/ kind: MessageKind, seq: String) {
        self.init()
        self.user = user
        self.senderID = user.senderId
        self.senderName = user.displayName
        self.content = content
        self.sentDate = Message.getDate()
//        self.created = sentDate
        self.kind = kind
        self.txState = "true"
        self.sequence = seq
    }
    
//    convenience init(content: String, user: User, /*messageId: String,*/ kind: MessageKind, seq: String) {
//        self.init(content: content, user: User, kind: kind, seq: seq)
//    }
    
    convenience init(realmMessage message: Message) {
        self.init()
        print(message)
        self.id = message.id
        self.user = message.user
        self.senderID = message.senderID
        self.senderName = message.senderName
        
        self.user = User(senderId: message.senderID, displayName: message.senderName)
        
        self.content = message.content
        self.sentDate = message.sentDate
//        self.created = message.sentDate
        self.kind = .text(message.content)
        self.txState = "true"
        self.sequence = message.sequence
    }
    
    convenience init?(document: QueryDocumentSnapshot) {
        self.init()
        let data = document.data()
        
//        print("Data : \(data)")
//        let sentDate = data["created"] as? Date{
//             self.sentDate = sentDate
//         }
        guard let _senderID = data["senderID"] as? String else { return nil }
        guard let _senderName = data["senderName"] as? String else { return nil }
        
        senderID = _senderID
        senderName = _senderName
        
        if let state = data["txState"] as? String {
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

    override static func primaryKey() -> String? {
        return "id"
    }
}

// MARK: DatabaseRepresentation
extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "txState" : txState,
            "sequence" : sequence,
//            "sentDate" : sentDate
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
        
    }
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.senderID == rhs.senderID
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
