//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Collection view for StyleMenuCollectionController.
final class StyleMenuCollectionView: IgnoreTouchesView {
        
    let collectionView: UICollectionView
    
    init() {
        collectionView = MenuCollectionView(frame: .zero, collectionViewLayout: MenuCollectionViewLayout())
        collectionView.accessibilityIdentifier = "Style Menu Collection"
        collectionView.backgroundColor = .clear
        
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
    
    // MARK: - Layout
    
    private func setUpViews() {
        collectionView.add(into: self)
        collectionView.clipsToBounds = false
    }
}


private class MenuCollectionView: IgnoreTouchesCollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        isScrollEnabled = true
        allowsSelection = true
        bounces = true
        alwaysBounceHorizontal = false
        alwaysBounceVertical = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = true
        reorderingCadence = .immediate
    }
}

private class MenuCollectionViewLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        scrollDirection = .vertical
        itemSize = UICollectionViewFlowLayout.automaticSize
        estimatedItemSize = CGSize(width: StyleMenuCollectionCell.width, height: StyleMenuCollectionCell.height)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
