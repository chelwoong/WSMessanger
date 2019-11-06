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
import Firebase

class ChatViewController: MessagesViewController, MessagesDataSource {
    
    // MARK: Variables
    private let currentUser: User
    private let channel: Channel
    private let db = Firestore.firestore()
    private var messageListener: ListenerRegistration?
    
    var messageList: [Message] = [
//        Message.init(text: "TESTTTTTT!", user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date()),
//        Message.init(text: "TESTTTTTT!", user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date()),
//        Message.init(text: "TESTTTTTT!", user: User(senderId: "123123", displayName: "Woongs"), messageId: UUID().uuidString, date: Date()),
//        Message.init(text: "TESTTTTTT!", user: User(senderId: "123123", displayName: "Woongs"), messageId: UUID().uuidString, date: Date())
    ]
    
    let refreshControl = UIRefreshControl()
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
 
    // MARK: - LifeCycle
    
    init(user: User, channel: Channel) {
        
        self.currentUser = user
        self.channel = channel
        
        super.init(nibName: nil, bundle: nil)
        
        title = channel.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        getMessage()
        fetchMessages()
    }
    
    
    // MARK: - Helpers
    
    func getMessage() {
        guard let channelID = channel.id else {return}
        let ref = db.collection(currentUser.id).document(channelID).collection("thread")
        
        ref.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // document.data() --> [String: Any]
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func fetchMessages() {
        guard let channelID = channel.id else {return}
        let ref = db.collection(currentUser.id).document(channelID).collection("thread")
        messageListener = ref.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                ("Error fetching documemnt: \(error!)")
                return
            }
            
            document.documentChanges.forEach { (change) in
                self.handleDocumentChange(change)
            }
            
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            print("handleDocumentChange \(change.type)")
            return
        }
        
        switch change.type {
        case .added:
            print(".added")
//            insertNewMessage(message)
            
//        case .modified:
//            print(".modified \(message.txState), sequence\(message.sequence)")
//            modifyMessage(message)
//
//        case .removed:
//            print(".deleted \(message.sequence)")
//            deleteMessage(message)
            
        default:
            print(".default")
            break
        }
    }
    
    func configureMessageCollectionView() {
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        //        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)))
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.addSubview(refreshControl)        
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        
    }
    
    
    private func save(_ message: Message) {
        
        var ref: CollectionReference
        guard let channelId = channel.id else { return }
        ref = db.collection(currentUser.id).document(channelId).collection("thread")
        
        ref.addDocument(data: [
            "content": message.content,
            "created": Date()
        ], completion: { (error) in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            else{
                //문자 전송시 실패를 할 수 있어서 해당 documentID를 다 저장해준다..
                //어딘가에다가
//                print("document ID :  \(String(describing: ref?.documentID))")
            }
            self.messagesCollectionView.scrollToBottom()
        })
    }
    
    func insertMessage(_ message: Message) {
        print("input msg: \(message.kind.self)")
        
//        self.save(message)
        messageList.append(message)
        save(message)
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
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    // MARK: - Message Datasource
    
    //// essential for cell
    /// it is necessary for control the message sent
    func currentSender() -> SenderType {
        return currentUser
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
        
        if !isFromCurrentSender(message: message) {
            
            let readAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),
                NSAttributedString.Key.foregroundColor: UIColor.orange
            ]
            let readAttributedString = NSAttributedString(string: "1", attributes: readAttributes)
            
            let whiteSpaceString = NSAttributedString(string: " ")
            
            bottomString.append(whiteSpaceString)
            bottomString.append(readAttributedString)
        }
        
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
        
        
//        let components = inputBar.inputTextView.components
//        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        let message = Message(content: text, user: self.currentUser, kind: .text(text))
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
//            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
//                self?.insertMessages(text)
                self?.insertMessage(message)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            
            if let str = component as? String {
//                let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
//                let message = Message.init(text: str, user: self.user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
            }
//            else if let img = component as? UIImage {
//                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//            }
        }
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    //    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    //        return .orange
    //    }
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    //    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
    //        switch detector {
    //        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
    //        default: return MessageLabel.defaultAttributes
    //        }
    //    }
    //
    //    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
    //        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    //    }
    //
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        /// 메세지 말풍선 꼬리 달기
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        if !isNextMessageSameSender(at: indexPath) {
            return .bubbleTail(tail, .curved)
        }
        return .bubble
        
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        //        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.primaryColor.cgColor
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        
        let shouldShow = Int.random(in: 0...10) == 0
        guard shouldShow else { return }
        
        let button = UIButton(type: .infoLight)
        button.tintColor = .primaryColor
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
    }
    
    
    
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    // read 부분
    //    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //        return 17
    //    }
    
    //
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
        return (!isNextMessageSameSender(at: indexPath) ? 16 : 0)
    }
    
}
