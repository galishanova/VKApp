//
//  NewsForm.swift
//  VK Client
//
//  Created by Regina Galishanova on 28.03.2021.
//

import Foundation
struct VKPost {
    
    let uswerName: String
    let userImageName: String
    let postImageName: String
    let numberOfLikes: String
    let numberOfShare: String
    let numberOfComments: String
    let numberOfViews: String
    let text: String?
}
    
func getNews() {
    
    var models = [VKPost]()

    
    models.append(VKPost(uswerName: "Jenner Kylie", userImageName: "jenner", postImageName: "jenner4", numberOfLikes: "6.4M", numberOfShare: "2.6K", numberOfComments: "2.3K", numberOfViews: "9.4M", text: "Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text "))
    models.append(VKPost(uswerName: "McGregor Conor", userImageName: "conor", postImageName: "conor4", numberOfLikes: "2.6M", numberOfShare: "46K", numberOfComments: "863K", numberOfViews: "7.2M", text: "Demo Text Demo Text "))
    models.append(VKPost(uswerName: "Apple", userImageName: "apple", postImageName: "iphone12", numberOfLikes: "12K", numberOfShare: "2K", numberOfComments: "4K", numberOfViews: "24K", text: "Demo Text Demo Text Demo Text Demo Text Demo Text "))
    models.append(VKPost(uswerName: "Travel Russia", userImageName: "rus trav", postImageName: "rus trav 2", numberOfLikes: "425", numberOfShare: "43", numberOfComments: "24", numberOfViews: "2K", text: ""))
    models.append(VKPost(uswerName: "Grande Ariana", userImageName: "grande", postImageName: "grande2", numberOfLikes: "2.6M", numberOfShare: "947K", numberOfComments: "376K", numberOfViews: "4M", text: "Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text Demo Text "))
    models.append(VKPost(uswerName: "Sport", userImageName: "sport", postImageName: "sport2", numberOfLikes: "836", numberOfShare: "56", numberOfComments: "359", numberOfViews: "32K", text: ""))
}


