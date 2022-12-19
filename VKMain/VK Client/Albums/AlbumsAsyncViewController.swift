import UIKit
import AsyncDisplayKit

class AlbumsAsyncViewController: ASDKViewController<ASDisplayNode>, ASCollectionDataSource, ASCollectionDelegate {
    
    let networkManager = NetworkManager()

    var albums: [Albums] = []
    
    var friendList: User!
    var friend: String = ""
    var userId: Int = 0
    
    
    var collectionNode: ASCollectionNode {
        return node as! ASCollectionNode
    }
    
    private enum Constants {
        static let padding: CGFloat = 5
        static let columns: CGFloat = 2
    }
    
    override init() {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        super.init(node: collectionNode)
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
        self.collectionNode.allowsSelection = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        collectionNode.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.loadAlbums()
        }
        collectionNode.reloadData()
        title = "\(friend)'s Albums"
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        albums.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = ((collectionNode.frame.width - (Constants.padding * 2)) - (Constants.padding * (Constants.columns - 1)))/Constants.columns
        let size = ASSizeRange(min: CGSize(width: width, height: 220), max: CGSize(width: width, height: 220))
        return size
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        guard albums.count > indexPath.row else { return { ASCellNode() } }

        let album = albums[indexPath.row]

        let cellNodeBlock = { () -> ASCellNode in
          let cellNode = AlbumsAsyncCellNode(source: album)
            
    
          return cellNode
            
        }

        return cellNodeBlock
    }
    

    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
     
        let controller = PhotoAsyncViewController()
        controller.albumId = album.albumId
        controller.albumTitle = album.title
        controller.ownerId = album.ownerId
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    private func loadAlbums() {
        networkManager.getUsersAlbums(token: Session.network.token, ownerId: String(self.userId)) { [weak self] (result) in
            guard let self = self else { return }
            switch result {

            case .success(let albumsArray):
                self.albums = albumsArray
                self.collectionNode.reloadData()

            case .failure(let error):
                print(error)

            }
        }
        
    }
}
