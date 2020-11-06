//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterSettingsViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let iconSize: CGFloat = 39
    static let padding: CGFloat = 4
    static let collectionViewHeight = CameraFilterCollectionCell.minimumHeight + 10
    static let height: CGFloat = collectionViewHeight + padding + iconSize
    
    // Redesign
    static let interspace: CGFloat = 8
    static var buttonSize: CGFloat {
        return CameraConstants.buttonSize
    }
    static var totalHeight: CGFloat {
        return collectionViewHeight + interspace + buttonSize
    }
}

protocol FilterSettingsViewDelegate: class {
    /// Callback for when the button that shows/hides the filter selector is tapped
    func didTapVisibilityButton()
}

/// View for filter settings
final class FilterSettingsView: IgnoreTouchesView {

    static let height: CGFloat = FilterSettingsViewConstants.height
    static let collectionViewHeight: CGFloat = FilterSettingsViewConstants.collectionViewHeight
    
    // Redesign
    static let totalHeight: CGFloat = FilterSettingsViewConstants.totalHeight
    
    let collectionContainer: IgnoreTouchesView
    let visibilityButton: UIButton
    private let settings: CameraSettings
    
    weak var delegate: FilterSettingsViewDelegate?
    
    init(settings: CameraSettings) {
        self.settings = settings
        
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Filter Collection Container"
        collectionContainer.clipsToBounds = false
        
        let defaultImage = settings.cameraToolsRedesign ? KanvasCameraImages.filtersImage : KanvasCameraImages.discoballUntappedImage
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
            
            if self.settings.cameraToolsRedesign {
                if shown {
                    image = KanvasCameraImages.filtersInvertedImage
                    backgroundColor = CameraConstants.buttonInvertedBackgroundColor
                }
                else {
                    image = KanvasCameraImages.filtersImage
                    backgroundColor = CameraConstants.buttonBackgroundColor
                }
            }
            else {
                image = shown ? KanvasCameraImages.discoballTappedImage : KanvasCameraImages.discoballUntappedImage
                backgroundColor = .clear
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
        
        let size: CGFloat
        
        if settings.cameraToolsRedesign {
            size = FilterSettingsViewConstants.buttonSize
            
            visibilityButton.backgroundColor = CameraConstants.buttonBackgroundColor
            visibilityButton.layer.cornerRadius = CameraConstants.buttonCornerRadius
            visibilityButton.layer.masksToBounds = true
        }
        else {
            size = FilterSettingsViewConstants.iconSize
        }

        NSLayoutConstraint.activate([
            visibilityButton.heightAnchor.constraint(equalToConstant: size),
            visibilityButton.widthAnchor.constraint(equalToConstant: size),
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
