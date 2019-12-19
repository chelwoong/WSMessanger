//
//  ChatRoomTC.swift
//  WSMessanger
//
//  Created by TTgo on 10/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import RealmSwift

struct preChatRoom{
    var state:String?
    var name:String?
    var peerName:String?
    var message:String?
    var sequence:String?
}


class ChannelViewController: UIViewController, SMSVCDelegate {
    
    var phone: String?
    var message: String?
    
    // MARK: - Properties

    var channels: [Channel] = []
    private let db = Firestore.firestore()
    private var channelListener: ListenerRegistration?
    private var userData = UserData.init()
    private var currentUser: User?
    private var fbUser: User?
    var peerNumber: String?
    var myId: String?
    var peerId: String?
    
    var notificationToken: NotificationToken?
    
    
    private var channelReference: CollectionReference {
        let email = myId!
        
        return db.collection(email)
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                //results.appendContentsOf(containerResults)
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.view.backgroundColor = .white
        
        if let account = userData.account {
            myId = userData.account
            currentUser = User(senderId: account, displayName: "test")
        }
                
        
        print(channels)
        // MARK: Lister 제거 -> Observe로 한 번만 가져오기
        
//        channelListener = channelReference.addSnapshotListener({ (querySnapshot, error) in
//            guard let snapshot = querySnapshot else {
//                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
//                return
//            }
//            snapshot.documentChanges.forEach { change in
//                if change.type != .added {
//                    self.handleDocumentChange(change)
//                }
//            }
//        })
        
        setupViews()
        setupTableView()
        
        // FB Observe
        observeChannels()
        
        // or Realm
//        guard let results = RealmManager.shared.getObjects(fileName: "channels", objType: Channel.self) else {return}
//        for channel in results {
//            self.channels.append(channel)
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Channels"
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Setups
    func setupViews() {
        
        view.addSubview(newTextButton)
        view.addSubview(tableView)
        
        
        newTextButton.anchor(top: nil, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 20, right: 50), size: .init(width: 0, height: 70))
        newTextButton.backgroundColor = .red
        newTextButton.addTarget(self, action: #selector(didTapNewTextButton(_:)), for: .touchUpInside)
        
        
        tableView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: newTextButton.topAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor)
        
    }
    
    func setupTableView() {
        self.tableView.register(ChannelCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: - Methods
    
    func unwindToViewController(){
 
        guard var peerNumber = phone else {return}
        
        peerNumber = peerNumber.replacingOccurrences(of: "-", with: "")
        peerNumber = peerNumber.replacingOccurrences(of: "+", with: "")
        peerNumber = peerNumber.replacingOccurrences(of: " ", with: "")
        peerNumber = peerNumber.replacingOccurrences(of: "(", with: "")
        peerNumber = peerNumber.replacingOccurrences(of: ")", with: "")
        print("========> peerNumber \(peerNumber), message \(message)")
        let sequence = Util.getSequence()
        createChannelorJustMoveIn(peer: peerNumber, msg: message, seq: sequence)
//        TTManager.sharedInstance.sendSMS(msg: message, to: peerNumber , seq: sequence)
        
    }
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        var result: [CNContact] = []
        
        for contact in self.contacts {
            if (!contact.phoneNumbers.isEmpty) {
                let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                for phoneNumber in contact.phoneNumbers {
                    let phoneNumberStruct = phoneNumber.value
                    let phoneNumberString = phoneNumberStruct.stringValue
                    let phoneNumberToCompare = phoneNumberString.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                    if phoneNumberToCompare == phoneNumberToCompareAgainst {
                        result.append(contact)
                    }
                }
            }
        }
        return result
    }

    
    public func findChannel(title name: String) -> Channel? {
        //let channel = channels[]
        for channel in channels{
            if channel.name == name {
                return channel
            }
        }
        return nil
    }
    
    public func createChannelorJustMoveIn(peer peerNumber:String , msg message:String?, seq sequence:String?) {
        var myNumber:String = "0"
        //파이어베이스 사용자 정보
//        print(currentUser?.displayName, currentUser)
//        guard let currUser = currentUser else { return }
        
//        if let v = Util.getSimNumber() { myNumber = v }
        //print("createChannel : \(channelName)")
        //channel name 은 해당 번호가 주소록에 잇을 경우 스위치를 한다.(나중에 추가할 것)
        var peerName = peerNumber
        //마지막으로 들어온 전화번호를 저장한다.
        //self.peerNumber = peerNumber
        
//        beforeChatRoom.name = peerName
//        beforeChatRoom.peerName = peerName
//        beforeChatRoom.message = message
//        beforeChatRoom.sequence = sequence
        
        // 이미 방이 개설이 되어 있는지 없는지를 확인한다.
        if let channel = findChannel(title: peerNumber ) {
//            beforeChatRoom.state = "false"
            print("createChannelorJustMoveIn channel:\(channel)")
            // 1초 뒤에 방에 들어간다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                 //메세지가 없어도 방에 들어가도록 수정
                
                let vc = ChatViewController(user: self.currentUser!, channel: channel, msg: message, seq: sequence)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            print("createChannelorJustMoveIn no channel")
            //처음 방을 개설할 때 주소록에서 이름이 있는지를 체크를 해서 있을 경우에 peerName 을 바꿔준다.
            let contact:[CNContact] = searchForContactUsingPhoneNumber(phoneNumber: peerNumber)
            if  contact.count > 0 {
                peerName = contact[0].givenName + " " + contact[0].familyName
                // 채팅방 이름이 바뀌면 구조체 정보도 바꿔준다.
//                beforeChatRoom.name = peerName
                print("found contact peerName \(peerName)")
                
                /// user name 추가
                userData.name = peerName
                self.currentUser?.displayName = peerName
            }
//            let channel = Channel(name: peerName, myNumber: myNumber, peerNumber: peerNumber, peerName: peerName)
            let newRef = channelReference.document()
            let channel = Channel(name: peerName, peerName: peerName, myNumber: myNumber, peerNumber: peerNumber, message: message)
            channel.id = newRef.documentID
            print(channel.dictionary)
            newRef.setData(
                    channel.dictionary
                
            ) { (err) in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
    //                self.channels.append(channel)
    //                self.tableView.reloadData()
                }
            }
            
            guard let currUser = currentUser else {return}
            guard let content = self.message else {return}
            
            let message = Message(content: content, user: currUser, kind: .text(content), seq: Util.getSequence())
            
            RealmManager.shared.saveObject(fileName: "channels", object: channel)
            enterChatRoom(channel: channel, user: currUser, message: message)
            
            //채널(방)이 없을 경우, 방을 만들고 방이 만들어지면 들어가는 쓰레드를 생성해서 처리한다.
            //DispatchQueue.main.async {
            //Show Progressing Bar
//            beforeChatRoom.state = "true"
//
//            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
//            loadingNotification.mode = MBProgressHUDMode.indeterminate
//            loadingNotification.label.text = "Processing for Creating ChatRoom"
//
//            StartTimer(from: "WaitingForChatRoom", delay: 5.0)
                //MBProgressHUD.hide(for: self.view, animated: true)
           // }
        }
    }
    
    @objc func didTapNewTextButton(_ sender: UIButton) {
        let vc = SMSViewController()
        vc.channelVC = self
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchChannels() {
        
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        print("in handleDocumentChange: \(channel.id)")
        
        switch change.type {
        case .added:
            //채널이 들어오면 백그라운드의 이미지를 지운다.
//            checkBackgroundDefaultObj()
            addChannelToTable(channel)
            channels.append(channel)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print(channel)

        case .modified:
            print("modified")
            updateChannelInTable(channel)
//
        case .removed:
            print("removed")
////            removeChannelFromTable(channel)
        default:
            print("default")
        }
    }
    
    func enterChatRoom(channel: Channel, user: User, message: Message?) {
        
        let vc: UIViewController
        if let msg = message {
            vc = ChatViewController(user: user, channel: channel, message: msg)
        } else {
            vc = ChatViewController(user: user, channel: channel)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(where: { (ch) -> Bool in
            return ch.id == channel.id
        }) else {
            print("**** could not access to index ****")
            return}
        channels[index] = channel
        channels.sort { $0.lastDate > $1.lastDate }
        self.tableView.reloadData()
    }
    
    private func addChannelToTable(_ channel: Channel) {
        guard !channels.contains(channel) else {return}
        
    }
    
    
    func observeChannels() {
        
        guard let account = myId else {return}
        db.collection(account).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("document: \(document.data())")
                    if let channel = Channel(document: document) {
                        self.channels.append(channel)
                        RealmManager.shared.saveObject(fileName: "channels", object: channel)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func didTapAddButton(sender: UIBarButtonItem) {
//        guard let account = userData.account else {return}
//        print(account)
//        let newChannelRef = db.collection(account).document()
//        let channel = Channel(name: account, peerName: "woongs", myNumber: "1234-2134", peerNumber: "010-1234-1234")
//        channel.id = newChannelRef.documentID
//
//        newChannelRef.setData(
//                channel.dictionary
//        ) { (err) in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("Document successfully written!")
////                self.channels.append(channel)
////                self.tableView.reloadData()
//            }
//        }
    }

    // MARK: Views
    private let newTextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "imgText")
        
        return imageView
    }()
    
    private let newTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New Text", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
}

// MARK: - TableView DataSource
extension ChannelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? ChannelCell else {
            return UITableViewCell()
        }

        cell.cellLabelTitle.text = channels[indexPath.row].peerName
        cell.cellLabelMessage.text = channels[indexPath.row].lastMsg
        
        cell.cellLabelLastDate.frame = CGRect(x:cell.frame.width-200, y:5, width:190, height:40 )
        cell.cellLabelLastDate.text = channels[indexPath.row].lastDate
        
        
        if channels[indexPath.row].read == "false" {
            cell.cellLabelRead.frame = CGRect(x:cell.frame.width-100, y:40, width:90, height:40 )
            cell.cellLabelRead.text = "New"
        }
        else{
            cell.cellLabelRead.text = ""
        }
        
        return cell
    }
}

extension ChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channels[indexPath.row]
        guard let currUser = currentUser else {return}

        enterChatRoom(channel: channel, user: currUser, message: nil)
    }
}
