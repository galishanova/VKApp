//
//  Group.swift
//  VK Client
//
//  Created by Regina Galishanova on 28.03.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Group: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var photo_100: String = ""
    @objc dynamic var screen_name: String = ""
    
    
    convenience init(from json: JSON) {
        self.init()
        
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.photo_100 = json["photo_100"].stringValue
        self.screen_name = json["screen_name"].stringValue
        
    }
}
