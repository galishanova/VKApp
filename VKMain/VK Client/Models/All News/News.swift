import UIKit
import SwiftyJSON
import RealmSwift



final class News: Object {

    @objc dynamic var type: String = ""
    @objc dynamic var date: Double = 0
    @objc dynamic var source_Id: Int = 0
    @objc dynamic var post_Id: Int = 0
    @objc dynamic var text: String = ""
    var isTextEmpty: Bool { return self.text == "" }
    @objc dynamic var markedAsAds: Int = 0
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var repostsCount: Int = 0
    @objc dynamic var viewsCount: Int = 0
    @objc dynamic var photo_Id: Int = 0
    @objc dynamic var access_key: Int = 0
    var sizes = List<SizeNews>()
    var isPhotoEmpty: Bool { return Size().url == "" }

    
    convenience init(from json: JSON) {
        self.init()
        self.type = json["type"].stringValue
        self.date = json["date"].doubleValue
        self.source_Id = json["source_id"].intValue
        self.post_Id = json["post_id"].intValue
        self.text = json["text"].stringValue
        self.markedAsAds = json["marked_as_ads"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.likesCount = json["likes"]["count"].intValue
        self.repostsCount = json["reposts"]["count"].intValue
        self.viewsCount = json["views"]["count"].intValue
        self.photo_Id = json["attachments"][0]["photo"]["id"].intValue
        self.access_key = json["attachments"][0]["photo"]["access_key"].intValue
//        self.postPhoto = json["attachments"][0]["photo"]["sizes"][3]["url"].stringValue
        let sizesArr = json["attachments"][0]["photo"]["sizes"].map { SizeNews(from: $1) }
    
        self.sizes.append(objectsIn: sizesArr)

    }
}

class SizeNews: Object {

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



