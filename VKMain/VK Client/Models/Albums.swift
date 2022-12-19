import Foundation
import SwiftyJSON
import RealmSwift

protocol AlbumSource {
    var title: String { get }
    var coverImageUrl: URL? { get }
}

class Albums: Object, AlbumSource {
    @objc dynamic var albumId: Int = 0
    @objc dynamic var thumbId: Int = 0
    @objc dynamic var ownerId: Int = 0
    @objc dynamic var albumTitle: String = ""
    @objc dynamic var photoCount: Int = 0
    var thumbSrc: URL?
    var sizes = List<PhotoSizesInAlbums>()
    
    convenience init(from json: JSON) {
        self.init()
        
        self.albumId = json["id"].intValue
        self.thumbId = json["thumb_id"].intValue
        self.ownerId = json["owner_id"].intValue
        self.albumTitle = json["title"].stringValue
        self.photoCount = json["size"].intValue
            let sizesArr = json["sizes"].map { PhotoSizesInAlbums(from: $1) }
        self.sizes.append(objectsIn: sizesArr)
    }
    
    var title: String { return "\(albumTitle)" }
    var coverImageUrl: URL? { return URL(string: sizes.last?.src ?? "") }
    
}

class PhotoSizesInAlbums: Object {
    @objc dynamic var src: String = ""
    @objc dynamic var height: Int = 0
    @objc dynamic var width: Int = 0
        
    convenience init(from json: JSON) {
        self.init()
        self.src = json["src"].stringValue
        self.height = json["height"].intValue
        self.width = json["width"].intValue
    }
}
