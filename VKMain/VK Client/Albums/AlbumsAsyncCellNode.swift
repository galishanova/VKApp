//
//  AlbumsAsyncCellNode.swift
//  VK Client
//
//  Created by Regina Galishanova on 07.05.2021.
//

import UIKit
import AsyncDisplayKit

class AlbumsAsyncCellNode: ASCellNode {
    private let source: AlbumSource
    private let albumTitle = ASTextNode()
    private let albumCover = ASNetworkImageNode()
    private let coverHeight: CGFloat = 150
    private let coverWidth: CGFloat = 300
    
    enum Constants {
        static let indent: CGFloat = 8
    }
    
    init(source: AlbumSource) {
        self.source = source
        
        super.init()
        backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        setupSubnodes()
        
    }
    
    private func setupSubnodes() {
        albumTitle.attributedText = NSAttributedString(string: source.title, attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.white])
        albumTitle.backgroundColor = .clear
        addSubnode(albumTitle)
        
        albumCover.url = source.coverImageUrl
        albumCover.cornerRadius = 5
        albumCover.clipsToBounds = true
        albumCover.shouldRenderProgressImages = false
        albumCover.contentMode = .scaleAspectFill
        addSubnode(albumCover)
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        albumCover.style.preferredSize = CGSize(width: coverWidth, height: coverHeight)
        
        let insets = UIEdgeInsets(top: Constants.indent, left: 0, bottom: Constants.indent, right: 0)
        let coverWithInsets = ASInsetLayoutSpec(insets: insets, child: albumCover)
        let titleCenterSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: albumTitle)
        
        let verticalStackSpec = ASStackLayoutSpec()
        verticalStackSpec.justifyContent = .start
        verticalStackSpec.direction = .vertical
        verticalStackSpec.children = [coverWithInsets, titleCenterSpec]
        
        let stackInsets = UIEdgeInsets(top: Constants.indent, left: Constants.indent, bottom: Constants.indent, right: Constants.indent)
        let stackWithIndents = ASInsetLayoutSpec(insets: stackInsets, child: verticalStackSpec)
        
        return stackWithIndents
    }
    
}
