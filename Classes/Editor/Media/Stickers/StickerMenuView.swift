//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the sticker menu view
protocol StickerMenuViewDelegate: class {
    
}

/// Constants for StickerMenuView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let backgroundColor: UIColor = .white
    static let bottomCollectionHeight: CGFloat = StickerTypeCollectionCell.totalHeight
    static let bottomCollectionCornerRadius: CGFloat = 30
}

/// A UIView for the sticker menu view
final class StickerMenuView: UIView {
        
    weak var delegate: StickerMenuViewDelegate?
    
    let mainCollectionContainer: UIView
    let bottomCollectionContainer: UIView
    
    // MARK: - Initializers
    
    init() {
        mainCollectionContainer = UIView()
        bottomCollectionContainer = UIView()
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setupMainCollectionContainer()
        setupBottomCollectionContainer()
    }
    
    private func setupMainCollectionContainer() {
        addSubview(mainCollectionContainer)
        mainCollectionContainer.accessibilityLabel = "Sticker Menu Main Collection Container"
        mainCollectionContainer.backgroundColor = Constants.backgroundColor
        mainCollectionContainer.translatesAutoresizingMaskIntoConstraints = false
        mainCollectionContainer.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            mainCollectionContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainCollectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomCollectionHeight),
            mainCollectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainCollectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupBottomCollectionContainer() {
        addSubview(bottomCollectionContainer)
        bottomCollectionContainer.accessibilityLabel = "Sticker Menu Bottom Collection Container"
        bottomCollectionContainer.backgroundColor = Constants.backgroundColor
        bottomCollectionContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomCollectionContainer.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            bottomCollectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomCollectionContainer.heightAnchor.constraint(equalToConstant: Constants.bottomCollectionHeight),
            bottomCollectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomCollectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
        
        bottomCollectionContainer.layer.cornerRadius = Constants.bottomCollectionCornerRadius
        bottomCollectionContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
}

