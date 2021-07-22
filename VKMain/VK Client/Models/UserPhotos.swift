//
//  UserPhotos.swift
//  VK Client
//
//  Created by Regina Galishanova on 20.02.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class UserPhotos: Object {
    @objc dynamic var photoDate: Double = 0.0
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerId: Int = 0
    @objc dynamic var postId: Int = 0
    @objc dynamic var text: String = ""
    @objc dynamic var likes: Int = 0
    @objc dynamic var reposts: Int = 0
    @objc dynamic var comments: Int = 0
    var sizes = List<Size>()

    
    convenience init(from json: JSON) {
        self.init()
        self.photoDate = json["date"].doubleValue
        self.id = json["id"].intValue
        self.likes = json["likes"]["count"].intValue
        self.ownerId = json["owner_id"].intValue
        self.postId = json["post_id"].intValue
        self.reposts = json["repost"]["count"].intValue
        self.comments = json["comments"]["count"].intValue
        self.text = json["text"].stringValue
            let sizesArr = json["sizes"].map { Size(from: $1) }
        self.sizes.append(objectsIn: sizesArr)

    }
}

class Size: Object {

    @objc dynamic var url: String = ""
    @objc dynamic var height: Int = 0
    @objc dynamic var width: Int = 0
    
    var aspectRatio: CGFloat { return CGFloat(height)/CGFloat(width) }
    
    convenience init(from json: JSON) {
        self.init()
        self.url = json["url"].stringValue
        self.height = json["height"].intValue
        self.width = json["width"].intValue
    }
}
