//
//  Util.swift
//  WSMessanger
//
//  Created by TTgo on 07/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit

class Util {
    
    init() {
        
    }
    
    static func getDate() -> Date {
        return Date()
    }
    
    static func getSequence() -> String{
        let defaults = UserDefaults.standard
        guard let sequence = defaults.string(forKey: "sequence")  else {
            // seq가 읽어지지 않으면 Unix time 으로 초기 값을 셋팅한다.
            let seq  = String(Int(NSDate().timeIntervalSince1970))
            print("timestamp Int : \(seq)")
            defaults.set( seq, forKey: "sequence")
            return seq
        }
        //print("timestamp : \(NSDate().timeIntervalSince1970)")
        print("+++ sequence : \(sequence)")
        let seq:Int = Int(sequence)! + 1
        print("sequence : \(sequence), (sequence) : \(seq))")
       // let seq = String( Int(sequence)! + 1 )
        defaults.set( String(seq), forKey: "sequence")
        return String(seq)
    }
    
//    static func getEmail() -> String? {
//        let ud: UserData = UserDefaults.string(<#T##self: UserDefaults##UserDefaults#>)
//        return
//    }
}
