//
//  ChatRoomTC.swift
//  WSMessanger
//
//  Created by TTgo on 10/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import Firebase

struct preChatRoom{
    var state:String?
    var name:String?
    var peerName:String?
    var message:String?
    var sequence:String?
}


class ChannelTableViewController: UITableViewController {
    
    // MARK: - Variables
    var channels: [Channel] = []
    private let db = Firestore.firestore()
    private var channelListener: ListenerRegistration?
    private var userData = UserData.init()
    private var currentUser: User?
    private var peerNumber: String?
    var myId: String?
    var peerId: String?
    
    private var channelReference: CollectionReference {
        let email = myId!
        
        return db.collection(email)
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        if let account = userData.account {
            myId = userData.account
        }
        print("Get User:\(userData.account)")
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Channels"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapAddButton(sender:)))
        self.tableView.register(ChannelCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        channelListener = channelReference.addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        })
        
//        observeChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Functions
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        print("in handleDocumentChange: \(channel.id)")
        
        switch change.type {
        case .added:
            //채널이 들어오면 백그라운드의 이미지를 지운다.
//            checkBackgroundDefaultObj()
//            addChannelToTable(channel)
            channels.append(channel)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        case .modified:
            print("modified")
            updateChannelInTable(channel)
//
        case .removed:
            print("removed")
////            removeChannelFromTable(channel)
//        default:
//            print("")
        }
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {return}
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
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
    
    }
    
    @objc func didTapAddButton(sender: UIBarButtonItem) {
        guard let account = userData.account else {return}

        let newChannelRef = db.collection(account).document()
        var channel = Channel(name: account, peerName: "woongs", myNumber: "1234-2134", peerNumber: "010-1234-1234")
        channel.id = newChannelRef.documentID

        newChannelRef.setData(
                channel.dictionary
        ) { (err) in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.channels.append(channel)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - TableView DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.channels.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
 

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channels[indexPath.row]
//        guard let currUser =
        print("channel state: \(channel.read)")
        let currentUser: User = .init(senderId: myId ?? "", displayName: "woongs")
        let vc = ChatViewController(user: currentUser, channel: channel)

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
