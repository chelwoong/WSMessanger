//
//  User.swift
//  WSMessanger
//
//  Created by TTgo on 02/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import Foundation
import MessageKit

struct User: SenderType, Equatable {
    
    public let senderId: String
    
    public var id: String {
        return senderId
    }

    /// The display name of a sender.
    public let displayName: String
    
    // MARK: - Intializers
    public init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
    
}
