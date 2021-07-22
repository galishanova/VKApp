//
//  GroupsOperations.swift
//  VK Client
//
//  Created by Regina Galishanova on 08.04.2021.
//

// MARK: - Get groups data with Operations

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class GroupsOperation {

    func getRequest(){
        
        let queue = OperationQueue()
        let receiveOperation = ReceiveGroupsData()
        let parseOperation = ParseGroupsData()
        let saveOperation = SaveGroupsToRealm()
        
        parseOperation.addDependency(receiveOperation)
        saveOperation.addDependency(parseOperation)

        let operations = [
            receiveOperation,
            parseOperation,
            saveOperation
        ]
        queue.addOperations(operations, waitUntilFinished: false)
    }
}

class ReceiveGroupsData: AsyncOperation {
    
    var outputData: Data?

    override func main() {
        let url = "https://api.vk.com/method/groups.get"
        let parameters: Parameters = [
            "extended": 1,
            "access_token": Session.network.token,
            "v": "5.92"
        ]
        AF.request(url, parameters: parameters).responseData { [weak self] (response) in
//            print(response)
            guard let data = response.data else {
                return
            }
            self?.outputData = data
            self?.state = .finished
        }
    }
}
class ParseGroupsData: Operation {
    
    var outputData: [Group]?
    
    override func main() {
        if let receiveOperation = dependencies.first as? ReceiveGroupsData {
            guard let data = receiveOperation.outputData else { return }
            do {
                let groupsResponse = try JSON(data: data)
                let groups = groupsResponse["response"]["items"].arrayValue.compactMap {
                    Group(from: $0)
                }
                outputData = groups
            } catch {
                print(error)
            }
        }
        
        
    }
}
class SaveGroupsToRealm: Operation {
    override func main() {
        if let parseOperation = dependencies.first as? ParseGroupsData {
            guard let groups = parseOperation.outputData else { return }
            RealmFunc().saveGroupData(groups)
        }
    }
    
    
    
}

