//
//  ThumbnailCollectionView.swift
//  FBSnapshotTestCase
//
//  Created by Gabriel Mazzei on 15/05/2020.
//

import Foundation
import UIKit

/// Collection view for ThumbnailCollectionController
final class ThumbnailCollectionView: UIView {
    
    let collectionViewLayout: ThumbnailCollectionViewLayout
    let collectionView: UICollectionView
    
    init() {
        collectionViewLayout = ThumbnailCollectionViewLayout()
        collectionView = ThumbnailInnerCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(frame: .zero)
        
        clipsToBounds = true
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
        collectionView.accessibilityIdentifier = "Thumbnail Collection View"
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .clear
    }
}


private class ThumbnailInnerCollectionView: UICollectionView {
    
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
        allowsSelection = false
        bounces = true
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = false
    }
}
