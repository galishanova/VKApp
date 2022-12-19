import UIKit
import RealmSwift

class MyCommunitiesController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableV: UITableView!
    @IBOutlet weak var searchCommBar: UISearchBar!
    
//MARK: - Searching
    var filteredCommunities: [Group]!
    var searching = false

//MARK: - Realm
    private let realmManager = RealmManager.shared
    var token: NotificationToken?
    
    var communities: Results<Group>?

//MARK: - Network
    let networkManager = NetworkManager()

    lazy var operationService = GroupsOperation()
    
// MARK: - cache
    lazy var cacheService = CacheService(container: tableV)


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableV.register(UINib(nibName: "MyCommunitiesCell", bundle: nil), forCellReuseIdentifier: "MyCommunitiesCell")
        
        tableV.delegate = self
        tableV.dataSource = self
        searchCommBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableV.reloadData()
        
        addRefreshControl()
        operationService.getRequest()
        pairGroupTableAndRealm()

    }
    
    private func addRefreshControl() {
        tableV.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            refreshControl.addTarget(self, action: #selector(reload(_:)), for: .valueChanged)
            return refreshControl
        }()
    }
    
    private func reloadGroupsList() {
        operationService.getRequest()
        self.tableV.refreshControl?.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if searching {
                return filteredCommunities?.count ?? 0
            } else {
                return communities?.count ?? 0
            }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MyCommunitiesCell.identifier, for: indexPath) as? MyCommunitiesCell {
            
                if let communities = communities {
                    if searching {
//                        cell.downLoadImage(from: filteredCommunities[indexPath.row].photo_100)
                        cell.myCommunity.text = filteredCommunities[indexPath.row].name
                        cell.myCommunityIcon.image = cacheService.photo(atIndexpath: indexPath, byUrl: filteredCommunities[indexPath.row].photo_100)

                    } else {
                        cell.myCommunity.text = communities[indexPath.row].name
//                        cell.downLoadImage(from: communities[indexPath.row].photo_100)
                        cell.myCommunityIcon.image = cacheService.photo(atIndexpath: indexPath, byUrl: communities[indexPath.row].photo_100)
                    }
                }

            return cell
        }
        return UITableViewCell()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCommunities = []
        
            if let communities = communities {
                if searchText == "" {
                    searching = false
                    self.tableV.reloadData()
                } else {
                    for community in communities {
                        if community.name.lowercased().contains(searchText.lowercased()) {
                            filteredCommunities.append(community)
                        }
                    }
                    searching = true
                    self.tableV.reloadData()
                }
            }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
        
    
    func pairGroupTableAndRealm() {
        guard let realm = try? Realm() else { return }
        communities = realm.objects(Group.self)
        token = communities?.observe { [weak self] changes in
            
            guard (self?.tableV) != nil else { return }
            
            switch changes {
            
            case .initial(let communities):
                print("Initialize \(communities.count)")
                self?.tableV.reloadData()
                break
                
            case .update(let communities, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print("""
                    New count \(communities.count)
                    Deletions \(deletions)
                    Insertions \(insertions)
                    Modifications \(modifications)
                    """
                    )
                
                self?.tableV.beginUpdates()
                        
                    self?.tableV.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                    self?.tableV.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                    self?.tableV.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0) }, with: .none)
                
                self?.tableV.endUpdates()
                
                break

            case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    @objc private func reload(_ sender: UIRefreshControl) {
        reloadGroupsList()
    }
    
}



