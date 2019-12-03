//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for StickerMenuView
private struct Constants {
    static let backgroundColor: UIColor = .white
    static let bottomCollectionHeight: CGFloat = StickerTypeCollectionCell.totalHeight
}

/// A view for the sticker menu controller
final class StickerMenuView: UIView {
        
    // Containers
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
    
    /// Sets up the view for the main sticker collection
    private func setupMainCollectionContainer() {
        addSubview(mainCollectionContainer)
        mainCollectionContainer.accessibilityIdentifier = "Sticker Menu Main Collection Container"
        mainCollectionContainer.backgroundColor = Constants.backgroundColor
        mainCollectionContainer.translatesAutoresizingMaskIntoConstraints = false
        mainCollectionContainer.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            mainCollectionContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainCollectionContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomCollectionHeight),
            mainCollectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainCollectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    /// Sets up the view for the sticker type collection shown at the bottom
    private func setupBottomCollectionContainer() {
        addSubview(bottomCollectionContainer)
        bottomCollectionContainer.accessibilityIdentifier = "Sticker Menu Bottom Collection Container"
        bottomCollectionContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomCollectionContainer.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            bottomCollectionContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomCollectionContainer.heightAnchor.constraint(equalToConstant: Constants.bottomCollectionHeight),
            bottomCollectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomCollectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
        
        bottomCollectionContainer.backgroundColor = Constants.backgroundColor
        bottomCollectionContainer.layer.masksToBounds = false
        bottomCollectionContainer.layer.shadowColor = UIColor.black.cgColor
        bottomCollectionContainer.layer.shadowOffset = CGSize(width: 0, height: -1.0)
        bottomCollectionContainer.layer.shadowOpacity = 0.15
        bottomCollectionContainer.layer.shadowRadius = 3.0
    }
}
