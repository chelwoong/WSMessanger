//
//  ChatRoomTC.swift
//  WSMessanger
//
//  Created by TTgo on 10/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import Firebase

class ChannelTC: UITableViewController {
    
    // MARK: - Variables
    var channels: [Channel] = []
    private let db = Firestore.firestore()
    
    private var currentUser: User?
    private var peerNumber: String?
    let myId = "woongs@ttgo.com"
    let peerId = "lanbi@naver.com"
    
    private var channelReference: CollectionReference {
        let email = myId
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
        let userData = UserData.init()
        print("Get User:\(userData.account), \(userData.password)")
        
        self.title = "Channels"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addButtonTapped(sender:)))
        
        self.tableView.register(ChannelCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        observeChannels()
        
    }
    
    // MARK: - Functions
    
    func observeChannels() {
        
//        let docRef = db.collection(myId)
        
        db.collection(myId).getDocuments { (querySnapshot, err) in
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
    
    @objc func addButtonTapped(sender: UIBarButtonItem) {

        
        
        let newChannelRef = db.collection(myId).document()
        var channel = Channel(name: "woongs", peerName: "lanbi", myNumber: "1234-2134", peerNumber: "010-1234-1234")
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

    // MARK: - Table view data source

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
        let currentUser: User = .init(senderId: myId, displayName: "woongs")
        let vc = ChatViewController(user: currentUser, channel: channel)
    
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
