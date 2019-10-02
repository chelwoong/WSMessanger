//
//  ChatViewController.swift
//  WSMessanger
//
//  Created by TTgo on 01/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    // MARK: Variables
    var messageList: [Message] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
    }
    
    func configureMessageInputBar() {
        
    }
}

// MARK: Message Datasource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return User()
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messageList[indexPath.section]
        return messageList[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messageList.count
//        return 0
    }
}

// MARK: Message cell delegate
extension ChatViewController: MessageCellDelegate {
    
}
