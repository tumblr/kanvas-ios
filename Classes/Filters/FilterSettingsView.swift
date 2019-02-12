//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterSettingsViewConstants {
    static let iconSize: CGFloat = 32
    static let padding: CGFloat = 10
    static var height: CGFloat = padding + FilterCollectionView.height + padding + iconSize
}

protocol FilterSettingsViewDelegate: class {
    /// Callback for when the button that shows/hides the filter selector is tapped
    func didTapVisibilityButton()
}

/// View for filter settings
final class FilterSettingsView: IgnoreTouchesView {

    static let height: CGFloat = FilterSettingsViewConstants.height
    
    let collectionContainer: IgnoreTouchesView
    let visibilityButton: UIButton
    
    weak var delegate: FilterSettingsViewDelegate?
    
    init() {
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Filter Collection Container"
        collectionContainer.clipsToBounds = false
        
        visibilityButton = UIButton()
        visibilityButton.accessibilityIdentifier = "Filter Visibility Button"
        visibilityButton.setBackgroundImage(KanvasCameraImages.filterImage, for: .normal)
        super.init(frame: .zero)
        
        clipsToBounds = false
        setUpViews()
        visibilityButton.addTarget(self, action: #selector(visibilityButtonTapped), for: .touchUpInside)
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
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
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            collectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collectionContainer.heightAnchor.constraint(equalToConstant: FilterCollectionView.height)
        ])
    }
    
    private func setUpVisibilityButton() {
        addSubview(visibilityButton)
        
        visibilityButton.isUserInteractionEnabled = true
        visibilityButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visibilityButton.heightAnchor.constraint(equalToConstant: FilterSettingsViewConstants.iconSize),
            visibilityButton.widthAnchor.constraint(equalToConstant: FilterSettingsViewConstants.iconSize),
            visibilityButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            visibilityButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
    }
}

// MARK: - Button handling
private extension FilterSettingsView {
    
    @objc func visibilityButtonTapped() {
        delegate?.didTapVisibilityButton()
    }
}
