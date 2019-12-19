//
//  RealmManager.swift
//  WSMessanger
//
//  Created by TTgo on 12/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import RealmSwift

struct RealmManager {
    static let shared = RealmManager()
    
    func getObjects<T: Object>(fileName: String, objType: T.Type) -> Results<T>? {
        var realmConfig = Realm.Configuration.defaultConfiguration
        if let fileURL = realmConfig.fileURL {
            realmConfig.fileURL = fileURL.deletingLastPathComponent().appendingPathComponent(fileName)
        }
        do {
            print(T.self)
            let realm = try Realm(configuration: realmConfig)
            return realm.objects(T.self)
        } catch let error {
            print("Get Object Error on Realm, \(error.localizedDescription)")
        }
        return nil
    }
    
    func saveObject<T: Object>(fileName: String, object: T) -> Void {
        var realmConfig = Realm.Configuration.defaultConfiguration
        if let fileURL = realmConfig.fileURL {
            realmConfig.fileURL = fileURL.deletingLastPathComponent()
                .appendingPathComponent(fileName)
        } 
        
        do {
            let realm = try Realm(configuration: realmConfig)
            try realm.write {
                realm.add(object, update: .error)
            }
        } catch {
            print("Save Object Error on Realm, \(error.localizedDescription)")
        }
    }
    
    func updateObject(fileName: String, updateFunc: @escaping () -> Void) -> Void {
        var realmConfig = Realm.Configuration.defaultConfiguration
        if let fileURL = realmConfig.fileURL {
            realmConfig.fileURL = fileURL.deletingLastPathComponent()
                .appendingPathComponent(fileName)
        }
        
        do {
            let realm = try Realm(configuration: realmConfig)
            try realm.write {
                updateFunc()
            }
        } catch {
            print("Update Object Error on Realm, \(error.localizedDescription)")
        }
    }
    
    func deleteObject<T: Object>(fileName: String, object: inout T) -> Void {
        var realmConfig = Realm.Configuration.defaultConfiguration
        if let fileURL = realmConfig.fileURL {
            realmConfig.fileURL = fileURL.deletingLastPathComponent()
                .appendingPathComponent(fileName)
        }
        
        do {
            let realm = try Realm(configuration: realmConfig)
            try realm.write {
                guard let obj = realm.object(ofType: T.self, forPrimaryKey: "id") else {
                    print("Can't find primaryKey")
                    return
                }
                realm.delete(obj)
            }
        } catch {
            print("Delete Object Error on Realm, \(error.localizedDescription)")
        }
    }
}

extension Results {
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}
