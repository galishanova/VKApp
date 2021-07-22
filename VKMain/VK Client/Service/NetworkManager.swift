//
//  NetworkManager.swift
//  VK Client
//
//  Created by Regina Galishanova on 11.02.2021.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

final class NetworkManager {
    
    //search groups
    func searchGroupsWithSwiftyJSON(token: String, searchText: String, completion: ((Result<[Group], Error>) -> Void)? = nil) {
        let baseURL = "https://api.vk.com"
        let path = "/method/groups.search"
        
        let params: Parameters = [
            "access_token": token,
            "q": searchText,
            "v": "5.92"
        ]
        
        AF.request(baseURL + path, method: .get, parameters: params).responseJSON(completionHandler: { (response) in
            switch response.result {

            case .success(let data):
                let json = JSON(data)
                let searchGroupJSON = json["response"]["items"].arrayValue
                let searchGroups = searchGroupJSON.map { Group(from: $0) }

                completion?(.success(searchGroups))

            case .failure(let error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        })
        
    }
    
//    //фотографии
    func getPhotosWithSwiftyJSON(token: String, albumId: Int, ownerId: String, completion: ((Result<[UserPhotos], Error>) -> Void)? = nil) {
        let url = "https://api.vk.com"
        let path = "/method/photos.get"
        let params = [
            "access_token": token,
            "owner_id": ownerId,
            "album_id": albumId,
            "extended": 1,
            "photo_sizes": 1,
            "rev": 1,
            "v": "5.130"
        ] as [String : Any]

        AF.request(url + path, method: .get, parameters: params).responseJSON(completionHandler: { (response) in
            switch response.result {

            case .success(let data):
                let json = JSON(data)
                let photoJSON = json["response"]["items"].arrayValue
                let photos = photoJSON.map { UserPhotos(from: $0) }

                completion?(.success(photos))

            case .failure(let error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        })
    }

    
    let myQueue = DispatchQueue(label: "myQueue",
                                qos: DispatchQoS.userInteractive,
                                attributes: DispatchQueue.Attributes.concurrent)
    let dispatchGroup = DispatchGroup()
    
    public func loadListNewsFeedVK(startTime: Double? = nil, startFrom: String = "", completionHandler: (([NewsGroup]?, [NewsUser]?, [News]?, Error?, String ) -> Void)? = nil) {
        
        let baseURL = "https://api.vk.com"
        let path = "/method/newsfeed.get"

        
        var params: Parameters = [
            "access_token": Session.network.token,
            "filters": "post",
            "count": "20",
            "start_from": startFrom,
            "v": "5.92"
        ]
        if let startTime = startTime {
            params["start_time"] = startTime
        }

        AF.request(baseURL + path, method: .get, parameters: params).responseJSON {
            (response) in
            switch response.result {
            case .failure(let error):
                completionHandler?(nil, nil, nil, error, "")
            case .success(let value):
                let json = JSON(value)
                
                var newsGroup = [NewsGroup]()
                var newsUser = [NewsUser]()
                
                let nextFrom = json["response"]["next_from"].stringValue
                
                self.myQueue.async(group: self.dispatchGroup) {
                    newsGroup = json["response"]["groups"].arrayValue.map { NewsGroup(json: $0) }
                }
                self.myQueue.async(group: self.dispatchGroup) {
                    newsUser = json["response"]["profiles"].arrayValue.map { NewsUser(json: $0) }
                }
                
                self.dispatchGroup.notify(queue: DispatchQueue.main) {
                    
                    let news = json["response"]["items"].arrayValue.map { News(from: $0) }
                    
                    DispatchQueue.main.async {
                        completionHandler?(newsGroup, newsUser, news, nil, nextFrom)
                    }

                }
            }
        }
    }
    
    func getUsersAlbums(token: String, ownerId: String, completion: ((Result<[Albums], Error>) -> Void)? = nil) {
        let url = "https://api.vk.com"
        let path = "/method/photos.getAlbums"
        let params = [
            "access_token": token,
            "owner_id": ownerId,
            "need_system": 1,
            "need_covers": 1,
            "photo_sizes": 1,
            "count": "1000",
            "v": "5.130"
        ] as [String : Any]

        AF.request(url + path, method: .get, parameters: params).responseJSON(completionHandler: { (response) in
            switch response.result {

            case .success(let data):
                let json = JSON(data)
                let albumsJSON = json["response"]["items"].arrayValue
                let albums = albumsJSON.map { Albums(from: $0) }

                completion?(.success(albums))
            case .failure(let error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        })
    }
    
}
