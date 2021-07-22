//
//  PostGroup.swift
//  VK Client
//
//  Created by Regina Galishanova on 03.04.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class NewsGroup: Object {
    
    @objc dynamic var group_Id = 0
    @objc dynamic var group_Name = ""
    @objc dynamic var group_Icon = ""
    
    convenience init(json: JSON) {
        self.init()
        
        self.group_Id = json["id"].intValue
        self.group_Name = json["name"].stringValue
        self.group_Icon = json["photo_50"].stringValue
    }
    
    override static func primaryKey() -> String? {
        return "group_Id"
    }
}
