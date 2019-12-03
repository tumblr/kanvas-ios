//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for StickerCollectionView
private struct Constants {
    static let numberOfColumns: Int = 4
    static let topInset: CGFloat = 24
    static let horizontalInset: CGFloat = 22
    static let loadingViewSize: CGFloat = 55
    static let loadingViewCornerRadius: CGFloat = 5
}

/// Collection view for StickerCollectionController
final class StickerCollectionView: UIView {
    
    private let loadingView: LoadingIndicatorView
    let collectionViewLayout: StaggeredGridLayout
    let collectionView: UICollectionView
    
    init() {
        loadingView = LoadingIndicatorView()
        collectionViewLayout = StaggeredGridLayout(numberOfColumns: Constants.numberOfColumns)
        collectionView = StickerInnerCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
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
        setUpCollectionView()
        setUpLoadingView()
    }
    
    private func setUpCollectionView() {
        collectionView.add(into: self)
        collectionView.accessibilityIdentifier = "Sticker Collection View"
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
    }
    
    private func setUpLoadingView() {
        addSubview(loadingView)
        loadingView.accessibilityIdentifier = "Sticker Collection Loading View"
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: Constants.loadingViewSize),
            loadingView.widthAnchor.constraint(equalToConstant: Constants.loadingViewSize)
        ])
        
        loadingView.layer.cornerRadius = Constants.loadingViewCornerRadius
        loadingView.layer.masksToBounds = true
    }
    
    // MARK: - Public interface
    
    func startLoading() {
        loadingView.alpha = 1
        loadingView.startLoading()
    }
    
    func stopLoading() {
        loadingView.stopLoading()
        loadingView.alpha = 0
    }
}


private class StickerInnerCollectionView: UICollectionView {
    
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
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = UIEdgeInsets(top: Constants.topInset, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = true
        reorderingCadence = .immediate
    }
}
