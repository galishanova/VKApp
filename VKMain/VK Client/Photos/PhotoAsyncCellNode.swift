import UIKit
import AsyncDisplayKit

class PhotoAsyncCellNode: ASCellNode {
    
    private let source: UserPhotos
    private let photo = ASNetworkImageNode()
    private let photoSize: CGFloat = 100

    
    init(source: UserPhotos) {
        self.source = source
        super.init()
        backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        setupSubnodes()
    }
    
    private func setupSubnodes() {
        photo.url = URL(string: source.sizes.last?.url ?? "")
        photo.clipsToBounds = true
        photo.shouldRenderProgressImages = true
        photo.contentMode = .scaleAspectFill
        addSubnode(photo)
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        photo.style.preferredSize = CGSize(width: photoSize, height: photoSize)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let imageWithInset = ASInsetLayoutSpec(insets: insets, child: photo)
        return ASWrapperLayoutSpec(layoutElement: imageWithInset)
    }
}
