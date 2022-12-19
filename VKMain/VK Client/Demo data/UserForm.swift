import Foundation



struct Friend {
    var name: String
    var surename: String
    var status: String?
    var online: String?
    var city: String?
    var study: String?
    var work: String?
    var image: String
    var allImages = [String]()
}

extension Friend: Equatable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.name == rhs.name
    }
}

let friend = Friend (name: "", surename: "", image: "", allImages: [""])


