//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterSettingsViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let iconSize: CGFloat = KanvasDesign.shared.filterSettingsViewIconSize
    static let padding: CGFloat = KanvasDesign.shared.filterSettingsViewPadding
    static let collectionViewHeight = CameraFilterCollectionCell.minimumHeight + 10
    static let height: CGFloat = collectionViewHeight + padding + iconSize
}

protocol FilterSettingsViewDelegate: AnyObject {
    /// Callback for when the button that shows/hides the filter selector is tapped
    func didTapVisibilityButton()
}

/// View for filter settings
final class FilterSettingsView: IgnoreTouchesView {

    static let height: CGFloat = FilterSettingsViewConstants.height
    static let collectionViewHeight: CGFloat = FilterSettingsViewConstants.collectionViewHeight
    
    let collectionContainer: IgnoreTouchesView
    let visibilityButton: UIButton
    
    weak var delegate: FilterSettingsViewDelegate?
    
    init() {        
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Filter Collection Container"
        collectionContainer.clipsToBounds = false
        
        let defaultImage = KanvasDesign.shared.filterSettingsViewFiltersOffImage
        visibilityButton = UIButton()
        visibilityButton.accessibilityIdentifier = "Filter Visibility Button"
        visibilityButton.setImage(defaultImage, for: .normal)
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
    
    // MARK: - Public interface
    
    /// Updates the UI when the filter collection changes its visibility
    ///
    /// - Parameter shown: whether the filter collection is now shown or hidden
    func onFilterCollectionShown(_ shown: Bool) {
        UIView.animate(withDuration: FilterSettingsViewConstants.animationDuration) { [weak self] in
            guard let self = self else { return }
            let image: UIImage?
            let backgroundColor: UIColor
            
            if shown {
                image = KanvasDesign.shared.filterSettingsViewFiltersOnImage
                backgroundColor = KanvasDesign.shared.filterSettingsViewButtonBackgroundInvertedColor
            }
            else {
                image = KanvasDesign.shared.filterSettingsViewFiltersOffImage
                backgroundColor = KanvasDesign.shared.filterSettingsViewButtonBackgroundColor
            }
            
            self.visibilityButton.backgroundColor = backgroundColor
            self.visibilityButton.setImage(image, for: .normal)
        }
    }
    
    /// Shows or hides the visibility button (discoball)
    ///
    /// - Parameter show: true to show, false to hide
    func showVisibilityButton(_ show: Bool) {
        UIView.animate(withDuration: FilterSettingsViewConstants.animationDuration) { [weak self] in
            self?.visibilityButton.alpha = show ? 1 : 0
        }
    }
}

// MARK: - UI Layout
private extension FilterSettingsView {
    
    func setUpViews() {
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
            collectionContainer.heightAnchor.constraint(equalToConstant: FilterSettingsViewConstants.collectionViewHeight)
        ])
    }
    
    func setUpVisibilityButton() {
        addSubview(visibilityButton)
        visibilityButton.translatesAutoresizingMaskIntoConstraints = false
        
        if KanvasDesign.shared.isBottomPicker {
            visibilityButton.backgroundColor = KanvasDesign.shared.filterSettingsViewButtonBackgroundColor
            visibilityButton.layer.cornerRadius = FilterSettingsViewConstants.iconSize / 2
            visibilityButton.layer.masksToBounds = true
        }

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
