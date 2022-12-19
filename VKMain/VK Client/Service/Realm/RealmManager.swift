import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    let realm: Realm
    
     init?() {
        let configurator = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        
        guard let realm = try? Realm(configuration: configurator) else { return nil }
        self.realm = realm
        
        print(realm.configuration.fileURL ?? "")
    }

    func add<T: Object>(object: T) throws {
        try realm.write {
            realm.add(object)
        }
        
    }
    
    func add<T: Object>(objects: [T]) throws {
        try realm.write {
            realm.add(objects, update: .modified)
        }
    }
    
    func getObjects<T: Object>() -> Results<T> {
        return realm.objects(T.self)
    }
    
    func delete<T: Object>(object: T) throws {
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() throws {
        try realm.write {
            realm.deleteAll()
        }
    }
    
    
    
}
