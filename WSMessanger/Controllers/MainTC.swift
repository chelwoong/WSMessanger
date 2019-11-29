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
        
        let friendsList = UINavigationController.init(rootViewController: ContactsListViewController())
        friendsList.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        let chatRoomTC = UINavigationController.init(rootViewController: ChannelViewController())
        chatRoomTC.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 1)
        
        let SMSVC = UINavigationController.init(rootViewController: SMSViewController())
        SMSVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 2)
        
        let tabBarList = [chatRoomTC, friendsList, SMSVC]
        
        viewControllers = tabBarList
        
        
    }
}
