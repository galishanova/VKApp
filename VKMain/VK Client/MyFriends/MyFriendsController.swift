//
//  MyFriendsController.swift
//  VK Client
//
//  Created by Regina Galishanova on 26.12.2020.
//

import UIKit
import RealmSwift
import PromiseKit


class MyFriendsController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableV: UITableView!
    @IBOutlet weak var searchFriendBar: UISearchBar!
    
    var selectedFriend: User!
    var selectedRow: User!


// MARK: - service
    private let networkManager = NetworkManager()

    private let userDataPromise = UsersDataPromise()
    
// MARK: - searching
    var searching = false
    var filteredFriend: [User]!
//    var filteredFriendsSectionTitles = [String]()
    
// MARK: - realm
    var token: NotificationToken?
    private let realmManager = RealmManager.shared
    var friends: Results<User>?
    
// MARK: - cache
    lazy var cacheService = CacheService(container: tableV)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableV.register(UINib(nibName: "MyFriendsCell", bundle: nil), forCellReuseIdentifier: "MyFriendsCell")
        tableV.delegate = self
        tableV.dataSource = self
        
        searchFriendBar.delegate = self
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableV.reloadData()
        
        addRefreshControl()
        pairFriendsTableAndRealm()
        userDataPromise.getFriendsList()
        
    }
    
    private func addRefreshControl() {
        tableV.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            refreshControl.addTarget(self, action: #selector(reload(_:)), for: .valueChanged)
            return refreshControl
        }()
    }
    
    private func reloadFriendsList() {
        userDataPromise.getFriendsList()
        self.tableV.refreshControl?.endRefreshing()
    }

    deinit {
        token?.invalidate()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            return filteredFriend.count
        } else {
            return friends?.count ?? 0
        }
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = (tableView.dequeueReusableCell(withIdentifier: "MyFriendsCell", for: indexPath) as? MyFriendsCell) {
            
            if searching {
                cell.friendName.text = filteredFriend? [indexPath.row].name
                cell.friendCity.text = filteredFriend? [indexPath.row].city
                cell.onlineStatus.isHidden = !((filteredFriend? [indexPath.row].isOnline)!)
                cell.friendPhotoProfile.image = cacheService.photo(atIndexpath: indexPath, byUrl: filteredFriend?[indexPath.row].avatar ?? ImageNetwork().nonePhoto)
            } else {
                cell.friendName.text = friends? [indexPath.row].name
                cell.friendCity.text = friends? [indexPath.row].city
                cell.onlineStatus.isHidden = !((friends? [indexPath.row].isOnline)!)
                cell.friendPhotoProfile.image = cacheService.photo(atIndexpath: indexPath, byUrl: friends?[indexPath.row].avatar ?? ImageNetwork().nonePhoto)
            }

            return cell
        }
        return UITableViewCell()

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            selectedFriend = filteredFriend?[indexPath.row]
        } else {
            selectedFriend = friends?[indexPath.row]
        }
        
        let controller = AlbumsAsyncViewController()
        controller.friend = friends?[indexPath.row].name ?? ""
        controller.userId = friends?[indexPath.row].id ?? 0
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
    
    @objc private func reload(_ sender: UIRefreshControl) {
        reloadFriendsList()
    }
}

extension MyFriendsController {
    
    //поиск в списке друзей
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredFriend = []

        if searchText == "" {
            searching = false
            self.tableV.reloadData()
        } else {
                if let friends = friends {

                   for friend in friends {
                       if friend.name.lowercased().contains(searchText.lowercased()) {
                           filteredFriend.append(friend)
                       }
                   }
               }
       
            searching = true
            self.tableV.reloadData()
        }
            self.tableV.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
}
 

extension MyFriendsController {
    
   private func pairFriendsTableAndRealm() {
        guard let realm =  try? Realm() else { return }
        friends = realm.objects(User.self)
        token = friends?.observe { [weak self] changes in
            guard (self?.tableV) != nil else { return }
            switch changes {

            case .initial(let users):
                print("Initialize \(users.count)")
                self?.tableV.reloadData()
                break

            case .update(let users, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print("""
                    New count \(users.count)
                    Deletions \(deletions)
                    Insertions \(insertions)
                    Modifications \(modifications)
                    """
                    )
                self?.tableV.reloadData()
                
                self?.tableV.beginUpdates()
//                self?.tableV.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
//                self?.tableV.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self?.tableV.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0) }, with: .none)

                self?.tableV.endUpdates()

                break

            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    
    
}

    





