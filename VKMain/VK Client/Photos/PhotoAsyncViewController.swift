import UIKit
import AsyncDisplayKit
import RealmSwift
import SwiftyJSON

class PhotoAsyncViewController: ASDKViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
    
    var photos: [UserPhotos]? = []
    
    let networkManager = NetworkManager()
    
    var albumTitle: String = ""
    var friend: String = ""
    var userId: Int = 0
    var ownerId = 0
    var albumId = 0
    var selectedPhotoIndex = 0

    
    var token: NotificationToken?
    
    var collectionNode: ASCollectionNode {
        return node as! ASCollectionNode
    }
    
    private enum Constants {
        static let padding: CGFloat = 5
        static let columns: CGFloat = 3
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
        super.viewWillAppear(animated)
        title = albumTitle
        DispatchQueue.main.async {
            self.collectionNode.reloadData()
        }
        DispatchQueue.global(qos: .background).async {
            self.getPhotos()
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = ((collectionNode.frame.width - (Constants.padding * 2)) - (Constants.padding * (Constants.columns - 1)))/Constants.columns
        return ASSizeRange(min: CGSize(width: width, height: width), max: CGSize(width: width, height: width))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard photos?.count ?? 0 > indexPath.row else { return { ASCellNode() } }

        let photo = photos![indexPath.row]

      let cellNodeBlock = { () -> ASCellNode in
        let cellNode = PhotoAsyncCellNode(source: photo)
        return cellNode
      }

      return cellNodeBlock
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FullPhotoViewController") as! FullPhotoViewController
        selectedPhotoIndex = indexPath.item
        vc.currentIndex = selectedPhotoIndex
        vc.photos = photos
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getPhotos() {
        self.networkManager.getPhotosWithSwiftyJSON(token: Session.network.token, albumId: self.albumId, ownerId: String(self.ownerId)) { [weak self] (result) in
            guard let self = self else { return }
            switch result {

            case .success(let photosArray):
                    self.photos = photosArray
                self.collectionNode.reloadData()

            case .failure(let error):
                print(error)

            }
        }
    }
}
