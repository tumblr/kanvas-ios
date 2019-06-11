//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterSmallCollectionViewConstants {
    static var bufferSize: CGFloat = 10
    static var height: CGFloat = FilterSmallCollectionCellConstants.minimumHeight + FilterSmallCollectionViewConstants.bufferSize
}

/// Collection view for the FilterSmallCollectionController
final class FilterSmallCollectionView: IgnoreTouchesView {
    
    static let height = FilterSmallCollectionViewConstants.height
    let collectionView: UICollectionView
    
    init() {
        collectionView = createCollectionView()
        
        super.init(frame: .zero)
        
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
}

// MARK: - Layout
extension FilterSmallCollectionView {
    
    private func setUpViews() {
        collectionView.add(into: self)
        collectionView.clipsToBounds = false
    }
    
}

// MARK: - Collection
fileprivate func createCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    configureCollectionLayout(layout: layout)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.accessibilityIdentifier = "Filter Collection"
    collectionView.backgroundColor = .clear
    configureCollection(collectionView: collectionView)
    return collectionView
}

fileprivate func configureCollectionLayout(layout: UICollectionViewFlowLayout) {
    layout.scrollDirection = .horizontal
    layout.itemSize = UICollectionViewFlowLayout.automaticSize
    layout.estimatedItemSize = CGSize(width: FilterSmallCollectionCellConstants.width, height: FilterSmallCollectionCellConstants.minimumHeight)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
}

fileprivate func configureCollection(collectionView: UICollectionView) {
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
