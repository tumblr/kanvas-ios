//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

protocol ThumbnailCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, widthForCellAt indexPath: IndexPath) -> CGFloat
}

final class ThumbnailCollectionViewLayout: UICollectionViewFlowLayout {

    weak var delegate: ThumbnailCollectionViewLayoutDelegate?

    private var contentWidth: CGFloat = 0
    private var contentHeight: CGFloat = 0
      
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
      
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        sectionInset = UIEdgeInsets(top: 0, left: TrimView.selectorMargin, bottom: 0, right: TrimView.selectorMargin)
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        cache.removeAll()
        contentHeight = ThumbnailCollectionCell.cellHeight
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        contentWidth = TrimView.selectorMargin
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
        
            let width = delegate?.collectionView(collectionView, widthForCellAt: indexPath) ?? ThumbnailCollectionCell.cellWidth
            let height = ThumbnailCollectionCell.cellHeight
            let frame = CGRect(x: contentWidth,
                               y: 0,
                               width: width,
                               height: height)
        
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentWidth += width
        }
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
