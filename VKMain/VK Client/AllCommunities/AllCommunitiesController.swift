//
//  AllCommunitiesController.swift
//  VK Client
//
//  Created by Regina Galishanova on 26.12.2020.
//

import UIKit

class AllCommunitiesController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchAllCommBar: UISearchBar!
    var searching = false

    var allCommunities: [Group]?
    let networkManager = NetworkManager()

// MARK: - cache
    lazy var cacheService = CacheService(container: tableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchAllCommBar.delegate = self
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return allCommunities?.count ?? 0
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommunityCell", for: indexPath) as? AllCommunitiesCell {
            if let allCommunities = allCommunities {
                cell.communityName.text = allCommunities[indexPath.row].name
                cell.communityIcon.image = cacheService.photo(atIndexpath: indexPath, byUrl: allCommunities[indexPath.row].photo_100)
            }
            return cell
        }
        return UITableViewCell()
    }

    //search community in VK
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        networkManager.searchGroupsWithSwiftyJSON(token: Session.network.token, searchText: searchText) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let groupsArray):

                DispatchQueue.main.async {
                    self.allCommunities = groupsArray

                    self.tableView.reloadData()
                }

            case .failure(let error):
                print(error)
            }
            
        }
        searching = true
        self.tableView.reloadData()
        
        
        if searchText == "" {
            if self.allCommunities != nil  {
                self.allCommunities?.removeAll()
                self.tableView.reloadData()
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
