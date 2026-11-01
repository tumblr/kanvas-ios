//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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

    struct Settings {
        let showsFadeOutGradient: Bool
    }

    private let settings: Settings
        
    init(settings: Settings) {
        collectionView = createCollectionView()
        self.settings = settings

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
        if settings.showsFadeOutGradient {
            setFadeOutGradient()
        }
    }
    
    private func setFadeOutGradient() {
        fadeOutGradient.frame = bounds
        fadeOutGradient.colors = [UIColor.clear.cgColor,
                                  UIColor.white.cgColor,
                                  UIColor.white.cgColor,
                                  UIColor.clear.cgColor]
        fadeOutGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadeOutGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadeOutGradient.locations = KanvasDesign.shared.mediaClipsCollectionViewFadeOutGradientLocations
        
        layer.mask = fadeOutGradient
    }
    
}

// MARK: - Collection
private func createCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    configureCollectionLayout(layout: layout)

    let collectionView = InteractiveMovementsCrashFixCollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.accessibilityIdentifier = "Media Clips Collection"
    collectionView.backgroundColor = .clear
    configureCollection(collectionView: collectionView)
    return collectionView
}

private func configureCollectionLayout(layout: UICollectionViewFlowLayout) {
    layout.scrollDirection = .horizontal
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

// Fixes a crash in `_UIDragFeedbackGenerator`: https://github.com/tumblr/kanvas-ios/issues/98
private class InteractiveMovementsCrashFixCollectionView: UICollectionView {
    // See https://stackoverflow.com/questions/51553223/handling-multiple-uicollectionview-interactivemovements-crash-uidragsnapping for more details
    override func cancelInteractiveMovement() {
        super.cancelInteractiveMovement()
        super.endInteractiveMovement() // animation will be ended early here
    }
}
