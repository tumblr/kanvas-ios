//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for PlaybackView
private struct Constants {
    static let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.65)
    static let cornerRadius: CGFloat = 18
}

/// View for the playback controller
final class PlaybackView: UIView {
    
    static let height: CGFloat = PlaybackCollectionCell.height
    
    let collectionView: UICollectionView
    private let layout: PlaybackCollectionViewLayout
    
    var cellWidth: CGFloat {
        set { layout.estimatedItemSize.width = newValue }
        get { layout.estimatedItemSize.width }
    }
    
    // MARK: - Initializers
    
    init() {
        layout = PlaybackCollectionViewLayout()
        collectionView = PlaybackInnerCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        
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
        collectionView.accessibilityIdentifier = "Playback Collection View"
        collectionView.backgroundColor = Constants.backgroundColor
        collectionView.layer.cornerRadius = Constants.cornerRadius
        collectionView.add(into: self)
    }
}


private class PlaybackInnerCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        isScrollEnabled = false
        allowsSelection = false
        bounces = false
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = false
    }
}

private class PlaybackCollectionViewLayout: UICollectionViewFlowLayout {

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
        estimatedItemSize = CGSize(width: PlaybackCollectionCell.width, height: PlaybackCollectionCell.height)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
