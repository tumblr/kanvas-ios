//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct ColorCollectionViewConstants {
    static var height: CGFloat =  ColorCollectionCell.height
}

/// Collection view for ColorCollectionController
final class ColorCollectionView: IgnoreTouchesView {
    
    let collectionView: HorizontalCollectionView
    static let height = ColorCollectionViewConstants.height
    let fadeOutGradient = CAGradientLayer()
    
    init() {
        let layout = HorizontalCollectionLayout(cellWidth: ColorCollectionCell.width, minimumHeight: ColorCollectionCell.height)
        collectionView = HorizontalCollectionView(frame: .zero, collectionViewLayout: layout, ignoreTouches: false)
        collectionView.accessibilityIdentifier = "Color Collection"
        
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
    
    private func setUpViews() {
        collectionView.add(into: self)
        collectionView.clipsToBounds = false
        setFadeOutGradient()
    }
    
    func updateFadeOutEffect() {
        fadeOutGradient.frame = bounds
    }
    
    private func setFadeOutGradient() {
        fadeOutGradient.frame = bounds
        fadeOutGradient.colors = [UIColor.clear.cgColor,
                                  UIColor.white.cgColor,
                                  UIColor.white.cgColor,
                                  UIColor.clear.cgColor]
        fadeOutGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadeOutGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadeOutGradient.locations = [0, 0.02, 0.9, 1.0]
        layer.mask = fadeOutGradient
    }
    
}
