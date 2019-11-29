//
//  UserData.swift
//  WSMessanger
//
//  Created by TTgo on 06/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import Foundation

public class UserData {
    
    var account: String?
    var password: String?
    var name: String?
    
    public init() {
        let defaults = UserDefaults.standard
        self.account = defaults.string(forKey: "Account")
        self.password = defaults.string(forKey: "Password")
        self.name = defaults.string(forKey: "name")
    }
}
