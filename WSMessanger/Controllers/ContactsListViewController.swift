//
//  FriendsListViewController.swift
//  WSMessanger
//
//  Created by TTgo on 07/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import Contacts

struct Contact {
    let name: String
}

class ContactsListViewController: UIViewController {
    
    let friendCell = "friendsCellId"
    var contacts: [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show IndexPath", style: .plain, target: self, action: nil)
        
        self.title = "Friends"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupViews()
        setupTableView()
        fetchContacts()
    }
    
    private func fetchContacts() {
        print("Attempting to fetch contacts")
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to request access:", error)
                return
            }
            
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        print(contact.givenName)
                        let contact = Contact(name: contact.givenName)
                        self.contacts.append(contact)
                    })
                } catch let err {
                    print("Failed to enumerate contacts", err)
                }
                
            } else {
                print("Access denied..")
            }
        }
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: friendCell)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupViews() {
        
        self.view.addSubview(tableView)
        
        tableView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor)
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    

}

// MARK: UITableView DataSource
extension ContactsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCell, for: indexPath)
//        cell.backgroundColor = .orange
        cell.textLabel?.text = contacts[indexPath.row].name
        return cell
    }
    
    
}

// MARK: UITableView Delegate
extension ContactsListViewController: UITableViewDelegate {
    
}
