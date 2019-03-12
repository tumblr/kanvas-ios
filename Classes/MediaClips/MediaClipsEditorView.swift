//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import TumblrTheme

private struct MediaClipsEditorViewConstants {
    static let animationDuration: TimeInterval = 0.5
    static let buttonHorizontalMargin: CGFloat = 16
    static let buttonRadius: CGFloat = 25
    static let nextButtonSize: CGFloat = 49
    static let nextButtonCenterYOffset: CGFloat = 3
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 6 + (Device.belongsToIPhoneXGroup ? 28 : 0)
}

protocol MediaClipsEditorViewDelegate: class {
    /// Callback for when next button is selected
    func nextButtonWasPressed()
}

/// View for media clips editor
final class MediaClipsEditorView: IgnoreTouchesView {
    
    static let height = MediaClipsCollectionView.height +
                        MediaClipsEditorViewConstants.topPadding +
                        MediaClipsEditorViewConstants.bottomPadding

    let collectionContainer: IgnoreTouchesView
    let nextButton: UIButton

    weak var delegate: MediaClipsEditorViewDelegate?

    init() {
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Media Clips Collection Container"
        collectionContainer.clipsToBounds = false

        nextButton = UIButton()
        nextButton.accessibilityIdentifier = "Media Clips Next Button"
        super.init(frame: .zero)
        
        clipsToBounds = false
        backgroundColor = KanvasCameraColors.translucentBlack
        setUpViews()
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
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
    
    /// shows or hides the complete view
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        UIView.animate(withDuration: MediaClipsEditorViewConstants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the preview button
    ///
    /// - Parameter show: true to show, false to hide
    func showPreviewButton(_ show: Bool) {
        UIView.animate(withDuration: MediaClipsEditorViewConstants.animationDuration) { [weak self] in
            self?.nextButton.alpha = show ? 1 : 0
        }
    }
}

// MARK: - UI Layout
private extension MediaClipsEditorView {

    func setUpViews() {
        setUpCollection()
        setUpNextButton()
    }
    
    func setUpCollection() {
        addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        let trailingMargin = MediaClipsEditorViewConstants.nextButtonSize + MediaClipsEditorViewConstants.buttonHorizontalMargin * 1.5
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -trailingMargin),
            collectionContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -MediaClipsEditorViewConstants.bottomPadding),
            collectionContainer.heightAnchor.constraint(equalToConstant: MediaClipsCollectionView.height)
        ])
    }
    
    func setUpNextButton() {
        addSubview(nextButton)
        nextButton.accessibilityLabel = "Next Button"
        nextButton.setImage(KanvasCameraImages.nextImage, for: .normal)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -MediaClipsEditorViewConstants.buttonHorizontalMargin),
            nextButton.heightAnchor.constraint(equalToConstant: MediaClipsEditorViewConstants.nextButtonSize),
            nextButton.widthAnchor.constraint(equalToConstant: MediaClipsEditorViewConstants.nextButtonSize),
            nextButton.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor, constant: -MediaClipsEditorViewConstants.nextButtonCenterYOffset)
        ])
    }

}

// MARK: - Button handling
extension MediaClipsEditorView {

    @objc func nextPressed() {
        delegate?.nextButtonWasPressed()
    }
}
