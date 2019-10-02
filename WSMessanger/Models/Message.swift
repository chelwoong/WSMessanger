//
//  Message.swift
//  WSMessanger
//
//  Created by TTgo on 01/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import MessageKit

struct Message: MessageType {
    
    
    var id: String = ""
    var content: String = ""
    var sentDate: Date
    var sender: SenderType
    var messageId: String = ""
    var kind: MessageKind
//    let sender: Sender
//    var txState: String = ""
//    var sequence: String = ""
    
    init(id: String, content: String, date: Date, sender: Sender, kind: MessageKind) {
        self.id = id
        self.content = content
        self.sentDate = date
        self.sender = sender
        self.kind = kind
    }
}
