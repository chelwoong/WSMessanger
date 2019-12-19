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
import RealmSwift

class ChatViewController: MessagesViewController, MessagesDataSource {
    
    // MARK: Properties
    private let user: User
    private let channel: Channel
    
    var message: Message?
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    private let db = Firestore.firestore()
    private var refChannelDoc: DocumentReference?
    private var refChatRoomCol: CollectionReference?
    
    private var storedMessage:String?
    private var storedSequence:String?
    
    let refreshControl = UIRefreshControl()
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a HH:mm"
        formatter.locale = Locale(identifier: "ko")
        return formatter
    }()
 
    // MARK: - Initialize
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(user: User, channel: Channel) {
        
        self.user = user
        self.channel = channel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(user: User, channel: Channel, message: Message) {
        self.init(user: user, channel: channel)
        self.message = message
    }
    
    // sms send init
    convenience init(user: User, channel: Channel, msg: String?, seq: String?) {
        self.init(user: user, channel: channel)
        self.storedMessage = msg
        self.storedSequence = seq
    }
    
    func printMsg(message: Message) {
        print(
            """
            In print Message!!
            \(message.sender),
            \(message.kind),
            \(message.sentDate),
            \(message.messageId)
            """
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(channel)
        print("Channel id::: \(channel.id)")
        guard let id = channel.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        refChannelDoc = db.collection(user.id).document(id)
        refChatRoomCol = db.collection([user.id, id, "thread"].joined(separator: "/"))
        
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
        // 새로운 SMS 체크
        if let message = self.message {
            self.save(message)
        }
        
        // get Messages from FB
//        fetchMessages()
        
        // or get data from Realm
        if let messages = RealmManager.shared.getObjects(fileName: id, objType: Message.self) {
            for message in messages {
                let msg = Message.init(realmMessage: message)
                insertMessage(msg)
            }
        } else {
            print("messages is nil")
        }
        
//        let customMenuItem = UIMenuItem(title: "Quote", action: #selector(MessageCollectionViewCell.quote(:_)))
//        UIMenuController.shared.menuItems = [customMenuItem]
    }
    
    // MARK: - Methods
    
    //메세지 읽음 상태로 변경함수
    private func setReadFlagTrue(){
        DispatchQueue.main.async() {
            self.refChannelDoc?.updateData([
                "read" : "true" // 읽었음
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    
    
    func fetchMessages() {
        
//        messageListener = refChatRoomCol?.addSnapshotListener { (documentSnapshot, error) in
//            guard let document = documentSnapshot else {
//                ("Error fetching documemnt: \(error!)")
//                return
//            }
//
//            document.documentChanges.forEach { (change) in
//                self.handleDocumentChange(change)
//            }
//        }
        
        refChatRoomCol?.getDocuments { (querySnapshot, error) in
            guard let document = querySnapshot else {
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
            print("handleDocumentChange \(change.document)")
            return
        }
        let docID = change.document.documentID
        message.id = docID
        switch change.type {
        case .added:
            print(".added")
//            print(type(of: message))
            self.insertMessage(message)
//            RealmManager.shared.saveObject(fileName: docID, object: message)
//            print(RealmManager.shared.getObjects(fileName: docID, objType: Message.self))
//            print(RealmManager.shared.getObjects(fileName: docID, objType: Message.self))

        case .modified:
            print(".modified \(message.txState), sequence\(message.sequence)")
//            modifyMessage(message)

        case .removed:
            print(".deleted \(message.sequence)")
            deleteMessage(message)

        default:
            print(".default")
            break
        }
        
        DispatchQueue.main.async {
           self.messagesCollectionView.scrollToBottom(animated: false)
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
        
        var ref: DocumentReference? = nil
        ref = refChatRoomCol?.addDocument(data: message.representation, completion: { (error) in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            else{
                //문자 전송시 실패를 할 수 있어서 해당 documentID를 다 저장해준다..
                //어딘가에다가
//                print("document ID :  \(String(describing: ref?.documentID))")
                guard let documentID = ref?.documentID else {return}
                message.id = documentID
                print("document ID : ", documentID)
                guard let channelID = self.channel.id else {return}
                print("channel ID : ", channelID)
                print("in save::::::::::::::::::::::::",message)
                RealmManager.shared.saveObject(fileName: channelID, object: message)
            }
            
            self.messagesCollectionView.scrollToBottom()
        })
        
        
        // 채팅방 정보 업데이트
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let lastDate = Util.getDate()
        
        refChannelDoc?.updateData([
            "lastMsg": message.content,
            "lastDate" : dateFormatter.string(from: lastDate)
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                RealmManager.shared.updateObject(fileName: "channels") {
                    self.channel.lastMsg = message.content
                    self.channel.lastDate = dateFormatter.string(from: lastDate)
                }
                
                print("Document successfully updated")
            }
        }
    }
    
    func insertMessage(_ message: Message) {

//        print("insert msg::: \(message)")
        
        
        printMsg(message: message)
        messages.append(message)
//        messages.sort { (m1, m2) -> Bool in
//            m1.sentDate < m2.sentDate
//        }
//
//        let index = messages.firstIndex(of: message)
//        let isLatestMessage = index == (messages.count - 1)
//        let shouldScrollToBottom = messagesCollectionView.isAtBottom
        
        messagesCollectionView.reloadData()

    }
    
    private func deleteSMS(in indexPath:IndexPath){
        
        //스크롤을 bottom 으로 갈 필요가 없다.
        let isLatestMessage = indexPath.section == (messages.count - 1)
        //만일 마지막 메세지이면 채널방 정보다 앞 정보로 업데이트를 한다.
        
        //삭제 하려는게 마지막 메세지일경우 앞의 메세지를 채팅방 정보로 업데이트 수행한다.
        //첫번째 메세지일 경우는 예외처리한다.
        if isLatestMessage, indexPath.section != 0 {
            let beforeIndex = indexPath.section - 1
            let text = messages[beforeIndex].content
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let sentDate = Util.getDate()
            self.refChannelDoc?.updateData([
                "lastMsg": text,
                "lastDate" : dateFormatter.string(from: sentDate)
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        
        //메세지를 삭제한다.
        let refDoc = refChatRoomCol!.document(messages[indexPath.section].id)
        DispatchQueue.main.async() {
            refDoc.delete()
        }
    }
    
    // 일치하는 메세지를 지움.
    private func deleteMessage(_ message: Message) {
        guard let index = messages.firstIndex(where: { (msg) -> Bool in
            msg.id == message.id
        }), let channelID = channel.id else { return }
                
        messages.remove(at: index)
        var message = message
        RealmManager.shared.deleteObject(fileName: channelID, object: &message)
        messagesCollectionView.reloadData()
    }
    
    // MARK: Helpers
    
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if action == NSSelectorFromString("delete:") {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
        
//        if action == NSSelectorFromString("delete:") {
//            return true
//        } else if action == NSSelectorFromString("quote:") {
//            return true
//        } else {
//            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        if action == NSSelectorFromString("delete:") {
            
            let message = messages[indexPath.item]
            
            showAlert {
                print("delete, \(message)")
                self.deleteSMS(in: indexPath)    // delete on FB
//                self.deleteMessage(message)    // delete on messages, Realm. listener에서 처리 
            }
            
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
        
//        if action == NSSelectorFromString("delete:") {
//            print("remove")
//        } else if action == NSSelectorFromString("quote:") {
//            print("quote")
//        } else {
//            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
//        }
    }
    
    func showAlert(handleDelete: @escaping () -> Void) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let destructive = UIAlertAction(title: "Delete", style: .destructive) { (alert) in
            handleDelete()
        }
        
        alert.addAction(cancel)
        alert.addAction(destructive)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 5 == 0
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        
        return messages[indexPath.section].user == messages[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].user == messages[indexPath.section + 1].user
    }
    
    // MARK: - Message Datasource
    
    /// essential for cell
    /// it is necessary for control the message sent
    func currentSender() -> SenderType {
        return user
//        return User(senderId: "asdf", displayName: "woongs")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        print("message for item",messages[indexPath.section])
        return messages[indexPath.section]
    }
    
    /// optional for name, date, ...
    ///
    // 메세지 3개마다 날짜 표시: 가운데 날짜
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        print(indexPath.section)
//        if indexPath.section % 3 == 0 {
//            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        }
        
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
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
//        print("\(indexPath), \(bottomString)")
        
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
//        messageInputBar.invalidatePlugins()

        let sequence = Util.getSequence()
        let message = Message(content: text, user: user, kind: .text(text), seq: sequence)

        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.save(message)
                inputBar.inputTextView.text = ""
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
    
    // MARK: Text Messages
    
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
    
    // MARK: All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        print(message, isFromCurrentSender(message: message))
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        /// 메세지 말풍선 꼬리 달기
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//        if !isNextMessageSameSender(at: indexPath) {
//            return .bubbleTail(tail, .curved)
//        }
        return .bubbleTail(tail, .curved)
        
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
        
//        accessoryView.subviews.forEach { $0.removeFromSuperview() }
//        accessoryView.backgroundColor = .clear
//
//        let shouldShow = Int.random(in: 0...10) == 0
//        guard shouldShow else { return }
//
//        let button = UIButton(type: .infoLight)
//        button.tintColor = .primaryColor
//        accessoryView.addSubview(button)
//        button.frame = accessoryView.bounds
//        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
//        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
//        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
        
        accessoryView.backgroundColor = .orange
        
        let label = UILabel()
        label.text = "heeellllo"
        
        accessoryView.addSubview(label)
    }
    
    
    
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if isTimeLabelVisible(at: indexPath) {
            return 15
        }
        return 0
        
//        if isTimeLabelVisible(at: indexPath) {
//            return 5
//        }
//        return 0
    }
    
     //read 부분
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
//        return (!isNextMessageSameSender(at: indexPath) ? 16 : 0)
        return 16
    }
    

}

extension MessageCollectionViewCell {
    
    override open func delete(_ sender: Any?) {
        
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
    
//    @objc func quote(_ sender: Any?) {
//
//        // Get the collectionView
//        if let collectionView = self.superview as? UICollectionView {
//            // Get indexPath
//            if let indexPath = collectionView.indexPath(for: self) {
//                // Trigger action
//                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.quote(_:)), forItemAt: indexPath, withSender: sender)
//            }
//        }
//    }
}
