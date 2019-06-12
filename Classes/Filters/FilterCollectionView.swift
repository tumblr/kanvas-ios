//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterCollectionViewPrivateConstants {
    static var bufferSize: CGFloat = 10
    static var height: CGFloat = FilterCollectionCellConstants.minimumHeight + FilterCollectionViewPrivateConstants.bufferSize
}

struct FilterCollectionViewConstants {
    static let height = FilterCollectionViewPrivateConstants.height
}

/// Collection view for the FilterCollectionController
class FilterCollectionView: IgnoreTouchesView {
    
    internal var height: CGFloat {
        return FilterCollectionViewConstants.height
    }
    
    internal var cellWidth: CGFloat {
        return FilterCollectionCellConstants.width
    }
    
    internal var cellMinimumHeight: CGFloat {
        return FilterCollectionCellConstants.minimumHeight
    }
    
    var collectionView: UICollectionView!

    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        
        collectionView = createCollectionView()
        clipsToBounds = false
        setUpViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        collectionView.add(into: self)
        collectionView.clipsToBounds = false
    }
    
    // MARK: - Collection
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        configureCollectionLayout(layout: layout)
        
        let collectionView = create(layout: layout)
        collectionView.accessibilityIdentifier = "Filter Collection"
        collectionView.backgroundColor = .clear
        configureCollection(collectionView: collectionView)
        return collectionView
    }
    
    internal func create(layout: UICollectionViewFlowLayout) -> UICollectionView {
        return IgnoreTouchesCollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    private func configureCollectionLayout(layout: UICollectionViewFlowLayout) {
        layout.scrollDirection = .horizontal
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: cellWidth, height: cellMinimumHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }
    
    private func configureCollection(collectionView: UICollectionView) {
        collectionView.isScrollEnabled = true
        collectionView.allowsSelection = true
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.autoresizesSubviews = true
        collectionView.contentInset = .zero
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.dragInteractionEnabled = true
        collectionView.reorderingCadence = .immediate
    }
}
