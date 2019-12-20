//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for DrawerTabBarView
private struct Constants {
    static let height = DrawerTabBarCell.height
}

/// Collection view for DrawerTabBarController
final class DrawerTabBarView: UIView {
    
    static let height = Constants.height
    
    let collectionView: UICollectionView
    
    init() {
        collectionView = DrawerTabBarCollectionView(frame: .zero, collectionViewLayout: DrawerTabBarCollectionViewLayout())
        collectionView.accessibilityIdentifier = "Drawer Tab Bar Collection View"
        collectionView.backgroundColor = .clear
        
        super.init(frame: .zero)
        
        clipsToBounds = false
        backgroundColor = .white
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


private class DrawerTabBarCollectionView: UICollectionView {
    
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
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = true
        reorderingCadence = .immediate
    }
}

private class DrawerTabBarCollectionViewLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        scrollDirection = .horizontal
        itemSize = UICollectionViewFlowLayout.automaticSize
        estimatedItemSize = CGSize(width: DrawerTabBarCell.width, height: DrawerTabBarCell.height)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
