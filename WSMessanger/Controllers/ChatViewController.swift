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

class ChatViewController: MessagesViewController, MessagesDataSource {
    
    // MARK: Variables
    var messageList: [Message] = [
        Message.init(text: "TESTTTTTT!", user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date()),
        Message.init(text: "TESTTTTTT!", user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date()),
        Message.init(text: "TESTTTTTT!", user: User(senderId: "123123", displayName: "Woongs"), messageId: UUID().uuidString, date: Date()),
        Message.init(text: "TESTTTTTT!", user: User(senderId: "123123", displayName: "Woongs"), messageId: UUID().uuidString, date: Date())
    ]
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        title = "Woongs"
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.addSubview(refreshControl)
//        refreshControl.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: Message) {
        print("input msg: \(message.kind)")
        
        messageList.append(message)
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }) { [weak self] _ in
            /// scroll to bottom when last message visible
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - Message Datasource
    
    //// essential for cell
    /// it is necessary for control the message sent
    func currentSender() -> SenderType {
        return SampleData.shared.currentSender
//        return User(senderId: "asdf", displayName: "woongs")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    //// optional for name, date, ...
    ///
    /// 메세지 3개마다 날짜 표시
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    /// 읽음
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//    }
    
    /// 이름
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        // 상대방 아이디만 보이기
        if !isFromCurrentSender(message: message) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
        
    }
    
    /// 날짜
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        let bottomString = NSMutableAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        
        return bottomString
    }
}



// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    /// for Audio Message cell
    
//    func didTapPlayButton(in cell: AudioMessageCell) {
//        guard let indexPath = messagesCollectionView.indexPath(for: cell),
//            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
//                print("Failed to identify message when audio cell receive tap gesture")
//                return
//        }
//        guard audioController.state != .stopped else {
//            // There is no audio sound playing - prepare to start playing for given audio message
//            audioController.playSound(for: message, in: cell)
//            return
//        }
//        if audioController.playingMessage?.messageId == message.messageId {
//            // tap occur in the current cell that is playing audio sound
//            if audioController.state == .playing {
//                audioController.pauseSound(for: message, in: cell)
//            } else {
//                audioController.resumeSound()
//            }
//        } else {
//            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
//            audioController.stopAnyOngoingPlaying()
//            audioController.playSound(for: message, in: cell)
//        }
//    }
//
//    func didStartAudio(in cell: AudioMessageCell) {
//        print("Did start playing audio sound")
//    }
//
//    func didPauseAudio(in cell: AudioMessageCell) {
//        print("Did pause audio sound")
//    }
//
//    func didStopAudio(in cell: AudioMessageCell) {
//        print("Did stop audio sound")
//    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - Message Input bar Delegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        /// input text
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user: User = SampleData.shared.currentSender
            if let str = component as? String {
//                let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
                let message = Message.init(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
//            else if let img = component as? UIImage {
//                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//            }
        }
    }
    
}
