//
//  NewsViewController.swift
//  VK Client
//
//  Created by Regina Galishanova on 17.01.2021.
//

import UIKit
import RealmSwift

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var table: UITableView!
    
    var news: [News] = []
    var newsGroup: Results<NewsGroup>?
    
    var nonePhoto = ImageNetwork().nonePhoto

    var newsUser: Results<NewsUser>?
    
    private var refreshControl = UIRefreshControl()
    let currentDate = Date().timeIntervalSince1970
    private var nextFrom = ""
    private var isLoading = false

    
    let networkManager = NetworkManager()
    
// MARK: - cache
    lazy var cacheService = CacheService(container: table)
    
    var token: NotificationToken?
    
//MARK: - zoom photo
    let blackBackgroundView = UIView()
    let zoomImageView = UIImageView()
    let navBarCoverView = UIView()
    let tabBarCoverView = UIView()

    var postImageView: UIImageView?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.prefetchDataSource = self
        self.getNews()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addRefreshControl()
        self.getNews()
        
        
    }
    
    private func addRefreshControl() {
        table.refreshControl = {
            refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
            return refreshControl
        }() 
    }
    
    private func getNews() {
        networkManager.loadListNewsFeedVK() { [weak self] newsGroup, newsUser, news, error, nextFrom  in
            guard let self = self, error == nil,
                let newsGroup = newsGroup, let newsUser = newsUser, let news = news else { print(error?.localizedDescription as Any); return }
            DispatchQueue.main.async {
            
                RealmFunc().saveNewsUserData(newsUser)
                RealmFunc().saveNewsGroupData(newsGroup)
                RealmFunc().saveNewsData(news)
                self.table.reloadData()
                self.news = news

                self.table.refreshControl?.endRefreshing()

            }
        }
        
    }
    
    private var dateFormatter: DateFormatter {
        let dt = DateFormatter()
        dt.dateFormat = "EEEE, HH:mm"
        return dt
    }
    
    @objc private func reload(_ sender: UIRefreshControl) {
        getNews()
    }
    
}

extension NewsViewController {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
            
            let newsF = news[indexPath.row]

            guard let realm = try? Realm() else { return UITableViewCell() }
            
//            if newsF.markedAsAds == 0 { //без рекламы
                
                if newsF.source_Id > 0, // новость друга
                   let newsU = realm.object(ofType: NewsUser.self, forPrimaryKey: newsF.source_Id) {
                    
                    cell.userNameLabel.text = "\( newsU.profiles_FirstName) \(newsU.profiles_LastName)"
                    cell.userImageView.image = cacheService.photo(atIndexpath: indexPath, byUrl: newsU.profiles_Icon)
                    
                } else if newsF.source_Id < 0, //новость группы
                    let newsG = realm.object(ofType: NewsGroup.self, forPrimaryKey: -newsF.source_Id) {
                    
                    cell.userNameLabel.text = newsG.group_Name

                    cell.userImageView.image = cacheService.photo(atIndexpath: indexPath, byUrl: newsG.group_Icon)
                }
               
                
                cell.postTextView.text = newsF.text
                
                cell.postImageView.image = cacheService.photo(atIndexpath: indexPath, byUrl: newsF.sizes.last?.url ?? "")

                cell.likesLabel.text = String(newsF.likesCount)
                cell.commentLabel.text = String(newsF.commentsCount)
                cell.shareLabel.text = String(newsF.repostsCount)
                cell.numberOfViewPost.text = String(newsF.viewsCount)
                cell.postTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(newsF.date))
)
                            
                cell.newsController = self
//            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{

        let tableWidth = tableView.bounds.width //ширина
        let news = self.news[indexPath.row]
        let photoHeight = tableWidth * (news.sizes.last?.aspectRatio ?? 0) //высота
        let postElemetsHeight = CGFloat(225)
        let heightForRowAt = photoHeight + postElemetsHeight
        return heightForRowAt
    }
    

}

extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        // Выбираем максимальный номер секции, которую нужно будет отобразить в ближайшее время
        guard let maxRow = indexPaths.map({ $0.row }).max() else { return } // 11
        // Проверяем,является ли эта ячейка одной из трех ближайших к концу
        if maxRow > news.count - 3 {

            isLoading = true

            print("loading: \(isLoading)")
            networkManager.loadListNewsFeedVK(startFrom: nextFrom) { [weak self] (newsGroup, newsUser, news, error, nextFrom) in

                guard let self = self else { return }
                DispatchQueue.main.async {

                    if let news = news {

                        let indexPaths = (self.news.count..<(self.news.count + news.count)).map { IndexPath(row: $0, section: 0)}

                        self.news.append(contentsOf: news)

                        self.table.insertRows(at: indexPaths, with: .automatic)
                    }

                    self.isLoading = false
                }
            }
        }

    }
    
    @objc func refreshNews() {
        self.refreshControl.beginRefreshing()
        let mostFreshNewsDate = self.news.first?.date

        networkManager.loadListNewsFeedVK(startTime: (mostFreshNewsDate ?? currentDate) + 1) { [weak self] newsGroup, newsUser, news, error, nextFrom in
            guard let self = self else { return }

            self.refreshControl.endRefreshing()
            
            guard news!.count > 0 else { return }
            
            if let news = news {

                let indexSet = (0..<news.count).map { IndexPath(row: $0, section: 0) }
                    
                self.news.insert(contentsOf: news, at: 0)

                self.table.insertRows(at: indexSet, with: .automatic)
            }
            
        }
        self.table.reloadData()
    }
    private func pairNewsGroupTableAndRealm() {
         guard let realm =  try? Realm() else { return }
        newsGroup = realm.objects(NewsGroup.self)
        token = newsGroup?.observe { [weak self] changes in
             guard (self?.table) != nil else { return }
             switch changes {

             case .initial(let newsGroup):
                 print("Initialize \(newsGroup.count)")
                 self?.table.reloadData()
                 break

             case .update(let feedGroup, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                 print("""
                     New count \(feedGroup.count)
                     Deletions \(deletions)
                     Insertions \(insertions)
                     Modifications \(modifications)
                     """
                     )
                 self?.table.reloadData()
                 self?.table.beginUpdates()
                     self?.table.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                     self?.table.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                     self?.table.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0) }, with: .automatic)

                 self?.table.endUpdates()

                 break

             case .error(let error):
                 fatalError("\(error)")
             }
         }
     }
//
//    private func pairNewsUserTableAndRealm() {
//         guard let realm =  try? Realm() else { return }
//        newsUser = realm.objects(NewsUser.self)
//        token = newsUser?.observe { [weak self] changes in
//             guard (self?.table) != nil else { return }
//             switch changes {
//
//             case .initial(let newsUser):
//                 print("Initialize \(newsUser.count)")
//                 self?.table.reloadData()
//                 break
//
//             case .update(let feedUser, deletions: let deletions, insertions: let insertions, modifications: let modifications):
//                 print("""
//                     New count \(feedUser.count)
//                     Deletions \(deletions)
//                     Insertions \(insertions)
//                     Modifications \(modifications)
//                     """
//                     )
//                 self?.table.reloadData()
//                 self?.table.beginUpdates()
//                     self?.table.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                     self?.table.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                     self?.table.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
//
//                 self?.table.endUpdates()
//
//                 break
//
//             case .error(let error):
//                 fatalError("\(error)")
//             }
//         }
//     }
    
    
    
    
}
 
    
extension NewsViewController {
    
    //zoom photo
    func animateImageView(postImageView: UIImageView) {
        self.postImageView = postImageView
        
        if let startingFrame = postImageView.superview?.convert(postImageView.frame, to: nil) {

            postImageView.alpha = 0 //выносит фото
                
            blackBackgroundView.frame = self.view.frame //черный задний фон за изображением
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            view.addSubview(blackBackgroundView)
            
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let navBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0 + (navigationController?.navigationBar.frame.height ?? 0.0)
            let navBarWidth = window?.windowScene?.statusBarManager?.statusBarFrame.width ?? 0 + (navigationController?.navigationBar.frame.width ?? 0.0)
            navBarCoverView.frame = CGRect(x: 0, y: 0, width: navBarWidth, height: navBarHeight)
            navBarCoverView.backgroundColor = UIColor.black
            navBarCoverView.alpha = 0

            if let keyWindow = UIApplication.shared.keyWindow { //спрятать tabbar & navbar
                keyWindow.addSubview(navBarCoverView)
                tabBarCoverView.frame = CGRect(x: 0, y: keyWindow.frame.height - 100, width: 1000, height: 100)
                tabBarCoverView.backgroundColor = UIColor.black
                tabBarCoverView.alpha = 0
                keyWindow.addSubview(tabBarCoverView)
            }
            
            zoomImageView.frame = startingFrame
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.image = postImageView.image
            zoomImageView.contentMode = .scaleAspectFill
//            zoomImageView.clipsToBounds = true //размер = размеру фото в таблице
            view.addSubview(zoomImageView)
            
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))

            UIView.animate(withDuration: 0.3) { () -> Void in
                //положение увеличенного изобр-я
                let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
                let y = self.view.frame.height / 2 - height / 2
                self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height) //размер изобр
                self.blackBackgroundView.alpha = 1
                self.navBarCoverView.alpha = 1
                self.tabBarCoverView.alpha = 1
            }
        }
    }
    
    
    @objc func zoomOut() {
        if let startingFrame = postImageView!.superview?.convert(postImageView!.frame, to: nil) {

            UIView.animate(withDuration: 0.3) {
                self.zoomImageView.frame = startingFrame
                self.blackBackgroundView.alpha = 0
                self.navBarCoverView.alpha = 0
                self.tabBarCoverView.alpha = 0
                
            } completion: { (didComplete) in
                
                self.zoomImageView.removeFromSuperview()
                self.blackBackgroundView.removeFromSuperview()
                self.navBarCoverView.removeFromSuperview()
                self.tabBarCoverView.removeFromSuperview()
                self.postImageView?.alpha = 1
            }

        }
    }
    
}


