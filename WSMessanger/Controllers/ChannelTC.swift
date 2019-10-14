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
    let db = Firestore.firestore()
    let myId = "woongs@ttgo.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        self.title = "Channels"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addButtonTapped(sender:)))
        
        self.tableView.register(ChannelCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        observeChannels()
        
    }
    
    // MARK: Functions
    
    func observeChannels() {
        db.collection("channels").whereField("id", isEqualTo: self.myId).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
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
        db.collection("channels").document().setData([
            "id" : "woongs@ttgo.com",
            "name" : "woongs",
            "myNumber" : "1234-2134",
            "peerId" : "2222-2222",
            "peerName" :  "lanbi",
            "lastMsg" : "heellooo",
            "read" : "false",
            "lastDate" : "112312312"
            
        ]) { (err) in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
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

        cell.cellLabelTitle.text = channels[indexPath.row].name
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
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(ChatViewController(), animated: true)
//        present(ChatViewController(), animated: true, completion: nil)
    }
}
