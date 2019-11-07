//
//  MainTC.swift
//  WSMessanger
//
//  Created by TTgo on 10/10/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit

class MainTC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendsList = ContactsListViewController()
        friendsList.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        let chatRoomTC = ChannelTableViewController()
        chatRoomTC.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 1)
        
        let tabBarList = [friendsList, chatRoomTC]
        
        viewControllers = tabBarList
        
        
    }
}
