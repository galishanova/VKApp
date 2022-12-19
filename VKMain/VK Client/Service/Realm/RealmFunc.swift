import Foundation
import RealmSwift

class RealmFunc {
    
    func savePhotoData(_ photo: [UserPhotos]) {

        do {
            let realm = try Realm()

            print(realm.configuration.fileURL!)
            
            let oldPhotoData = realm.objects(UserPhotos.self)

            realm.beginWrite()
            
            realm.delete(oldPhotoData)

            realm.add(photo)

            try realm.commitWrite()
            
        } catch {
            print(error)
        }
    }

    func deleteAllRealmPhotoData() {
        do {
            let realm = try Realm()
            
            let photoData = realm.objects(UserPhotos.self)
            
            realm.beginWrite()
            
            realm.delete(photoData)
            
            try realm.commitWrite()
            
        } catch {
            print(error)
        }
    }
    
    func saveGroupData(_ group: [Group]) {
        
        do {
            let realm = try Realm()
            
            print(realm.configuration.fileURL as Any)

            let oldGroupData = realm.objects(Group.self)
            
            realm.beginWrite()
            
            realm.delete(oldGroupData)

            realm.add(group)
            
            try realm.commitWrite()
            
        } catch {
            print(error)
        }
    }
    
    func saveNewsData(_ news: [News]) {

        do {
            let realm = try Realm()

            print(realm.configuration.fileURL as Any)

            let oldNewsData = realm.objects(News.self)
            
            realm.beginWrite()
            
            realm.delete(oldNewsData)
                
            realm.add(news)

            try realm.commitWrite()

        } catch {
            print(error)

            }
    }
    
    func saveNewsGroupData(_ newsGroup: [NewsGroup]) {

        do {
            let realm = try Realm()

            print(realm.configuration.fileURL as Any)

            let oldNewsGroupData = realm.objects(NewsGroup.self)
            
            realm.beginWrite()
            
            realm.delete(oldNewsGroupData)
                
            realm.add(newsGroup)

            try realm.commitWrite()

        } catch {
            print(error)

            }
    }
    
    func saveNewsUserData(_ newsUser: [NewsUser]) {

        do {
            let realm = try Realm()

            print(realm.configuration.fileURL as Any)

            let oldNewsUserData = realm.objects(NewsUser.self)
            
            realm.beginWrite()
            
            realm.delete(oldNewsUserData)
                
            realm.add(newsUser)

            try realm.commitWrite()

        } catch {
            print(error)

            }
    }
    
    func saveAlbumsData(_ album: [Albums]) {

        do {
            let realm = try Realm()

            print(realm.configuration.fileURL!)
            
            let oldAlbumsData = realm.objects(Albums.self)

            realm.beginWrite()
            
            realm.delete(oldAlbumsData)

            realm.add(album)

            try realm.commitWrite()
            
        } catch {
            print(error)
        }
    }

}
