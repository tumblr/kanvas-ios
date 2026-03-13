//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

protocol ThumbnailCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, widthForCellAt indexPath: IndexPath) -> CGFloat
}

/// Constants for ThumbnailCollectionViewLayout
private struct Constants {
    static let section: Int = 0
}

/// Layout for the thumbnail collection in the GIF maker.
final class ThumbnailCollectionViewLayout: UICollectionViewFlowLayout {

    weak var delegate: ThumbnailCollectionViewLayoutDelegate?

    private let contentHeight: CGFloat = ThumbnailCollectionCell.cellHeight
    private var contentWidth: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
      
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: TrimView.selectorMargin, bottom: 0, right: TrimView.selectorMargin)
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView, let delegate = delegate else { return }
        
        cache.removeAll()
        
        contentWidth = sectionInset.left
        for item in 0..<collectionView.numberOfItems(inSection: Constants.section) {
            let indexPath = IndexPath(item: item, section: Constants.section)
            
            let cellWidth = delegate.collectionView(collectionView, widthForCellAt: indexPath)
            let cellHeight = ThumbnailCollectionCell.cellHeight
            
            let cellFrame = CGRect(x: contentWidth,
                                   y: 0,
                                   width: cellWidth,
                                   height: cellHeight)
        
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = cellFrame
            cache.append(attributes)
            
            contentWidth += cellWidth
        }
        
        contentWidth += sectionInset.right
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
          var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

          for attributes in cache {
              if attributes.frame.intersects(rect) {
                  visibleLayoutAttributes.append(attributes)
              }
          }
          return visibleLayoutAttributes
      }
    
      override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
          return cache[indexPath.item]
      }
}
