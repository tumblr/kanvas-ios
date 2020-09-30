//
//  MediaClipsCollectionView.swift
//  KanvasEditor
//
//  Created by Daniela Riesgo on 26/07/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation
import UIKit

private struct MediaClipsCollectionViewConstants {
    static var bufferSize: CGFloat = 10
    static var height: CGFloat = MediaClipsCollectionCell.minimumHeight + MediaClipsCollectionViewConstants.bufferSize
}

/// Collection view for the MediaClipsCollectionController
final class MediaClipsCollectionView: UIView {

    static let height = MediaClipsCollectionViewConstants.height
    let collectionView: UICollectionView
    let fadeOutGradient = CAGradientLayer()

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
    
    func updateFadeOutEffect() {
        fadeOutGradient.frame = bounds
    }
}

// MARK: - Layout
extension MediaClipsCollectionView {

    private func setUpViews() {
        collectionView.add(into: self)
        collectionView.clipsToBounds = false
        setFadeOutGradient()
    }
    
    private func setFadeOutGradient() {
        fadeOutGradient.frame = bounds
        fadeOutGradient.colors = [UIColor.clear.cgColor,
                                  UIColor.white.cgColor,
                                  UIColor.white.cgColor,
                                  UIColor.clear.cgColor]
        fadeOutGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadeOutGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadeOutGradient.locations = [0, 0.05, 0.9, 1.0]
        layer.mask = fadeOutGradient
    }
    
}

// MARK: - Collection
private func createCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    configureCollectionLayout(layout: layout)

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.accessibilityIdentifier = "Media Clips Collection"
    collectionView.backgroundColor = .clear
    configureCollection(collectionView: collectionView)
    return collectionView
}

private func configureCollectionLayout(layout: UICollectionViewFlowLayout) {
    layout.scrollDirection = .horizontal
    layout.itemSize = UICollectionViewFlowLayout.automaticSize
    layout.estimatedItemSize = CGSize(width: MediaClipsCollectionCell.width, height: MediaClipsCollectionCell.minimumHeight)
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
