//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterSettingsViewDelegate: class {
    func visibilityButtonPressed()
}

private struct FilterSettingsViewConstants {
    static let iconSize: CGFloat = 32
    static let padding: CGFloat = 25
    static var height: CGFloat = padding + FilterCollectionView.height + padding
}

/// View that handles the filter settings
final class FilterSettingsView: IgnoreTouchesView {
    weak var delegate: FilterSettingsViewDelegate?
    
    static let height: CGFloat = FilterSettingsViewConstants.height
    
    let collectionContainer: IgnoreTouchesView
    private let visibilityButton: UIButton
    
    init() {
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Filter Collection Container"
        collectionContainer.clipsToBounds = false
        
        visibilityButton = UIButton()
        visibilityButton.accessibilityIdentifier = "Filter Visibility Button"
        super.init(frame: .zero)
        clipsToBounds = false
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Layout
private extension FilterSettingsView {
    
    private func setUpViews() {
        setUpCollection()
        setUpVisibilityButton()
    }
    
    func setUpCollection() {
        addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            collectionContainer.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor,
                                                        constant: -FilterSettingsViewConstants.padding),
            collectionContainer.heightAnchor.constraint(equalToConstant: FilterCollectionView.height)
        ])
    }
    
    private func setUpVisibilityButton() {
        addSubview(visibilityButton)
        
        visibilityButton.setBackgroundImage(KanvasCameraImages.filterImage, for: .normal)
        visibilityButton.addTarget(self, action: #selector(visibilityButtonPressed), for: .touchUpInside)
        visibilityButton.isUserInteractionEnabled = true
        visibilityButton.translatesAutoresizingMaskIntoConstraints = false
        visibilityButton.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            visibilityButton.heightAnchor.constraint(equalToConstant: FilterSettingsViewConstants.iconSize),
            visibilityButton.widthAnchor.constraint(equalToConstant: FilterSettingsViewConstants.iconSize),
            visibilityButton.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            visibilityButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor)
        ])
    }
}

// MARK: - Button handling
private extension FilterSettingsView {
    
    @objc private func visibilityButtonPressed() {
        delegate?.visibilityButtonPressed()
    }
}
