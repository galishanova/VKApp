//
//  UsersDataPromise.swift
//  VK Client
//
//  Created by Regina Galishanova on 11.04.2021.
//

import UIKit
import PromiseKit
import Alamofire
import SwiftyJSON
import RealmSwift

class UsersDataPromise {
    
    func getFriendsList(){
        firstly {
            getUsersData()
        }.then { data in
            self.parseData(data: data)
        }.done { users in
            self.saveUserData(users)
        }.catch { error in
            print(error)
        }
    }
    
    func getUsersData() -> Promise<Data>{
        let promise = Promise<Data> { (resolver) in
            let url = "https://api.vk.com/method/friends.get"
            let params: Parameters = [
                    "access_token": Session.network.token,
                    "order": "name",
                    "fields": "domain, bdate, photo_200, city, online",
                    "v": "5.21"
                ]
            AF.request(url, parameters: params).responseData { (response) in
                if let data = response.data {
                    resolver.fulfill(data)
                }
            }
        }
        return promise
    }
    
    func parseData(data: Data) -> Promise<[User]> {
        let promise = Promise<[User]> { (resolver) in
            do {
                let usersResponse = try JSON(data: data)
                let users = usersResponse["response"]["items"].arrayValue.compactMap {
                    User(from: $0)
                }
                resolver.fulfill(users)
            } catch {
                resolver.reject(error)
            }
        }
        return promise
    }
    
    func saveUserData(_ user: [User]) {
        
        do {
            let realm = try Realm()
            
            print(realm.configuration.fileURL as Any)

            let oldUserData = realm.objects(User.self)
            
            realm.beginWrite()
            
            realm.delete(oldUserData)

            realm.add(user)
            
            try realm.commitWrite()
            
        } catch {
            print(error)
        }
    }

}
