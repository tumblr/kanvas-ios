//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// protocol for closing the preview or confirming

protocol EditorViewDelegate: class {
    /// A function that is called when the confirm button is pressed
    func confirmButtonPressed()
    /// A function that is called when the close button is pressed
    func closeButtonPressed()
    /// A function that is called when the button to close a menu is pressed
    func closeMenuButtonPressed()
}

/// Constants for EditorView
private struct EditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let confirmButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
    static let closeMenuButtonSize: CGFloat = 36
    static let closeMenuButtonHorizontalMargin: CGFloat = 20
}

/// A UIView to preview the contents of segments without exporting

final class EditorView: UIView {
    
    weak var playerView: GLPlayerView?
    
    private let confirmButton = UIButton()
    private let closeMenuButton = UIButton()
    private let closeButton = UIButton()
    let collectionContainer = IgnoreTouchesView()
    
    private var disposables: [NSKeyValueObservation] = []
    weak var delegate: EditorViewDelegate?
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        let playerView = GLPlayerView()
        playerView.add(into: self)
        self.playerView = playerView

        setUpCloseButton()
        setUpCloseMenuButton()
        setUpConfirmButton()
        setUpCollection()
    }
    
    // MARK: - views
    
    private func setUpCloseButton() {
        closeButton.accessibilityLabel = "Close Button"
        closeButton.applyShadows()
        closeButton.setImage(KanvasCameraImages.backImage, for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: CameraConstants.optionHorizontalMargin),
            closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize)
        ])
    }
    
    private func setUpCloseMenuButton() {
        closeMenuButton.accessibilityLabel = "Close Menu Button"
        closeMenuButton.setImage(KanvasCameraImages.confirmImage, for: .normal)
        closeMenuButton.imageView?.contentMode = .scaleAspectFit
        closeMenuButton.alpha = 0
        
        addSubview(closeMenuButton)
        closeMenuButton.addTarget(self, action: #selector(closeMenuButtonPressed), for: .touchUpInside)
        closeMenuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeMenuButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.closeMenuButtonHorizontalMargin),
            closeMenuButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.closeMenuButtonSize),
            closeMenuButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.closeMenuButtonSize),
            closeMenuButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
    }
    
    private func setUpConfirmButton() {
        confirmButton.accessibilityLabel = "Confirm Button"
        addSubview(confirmButton)
        confirmButton.setImage(KanvasCameraImages.nextImage, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.confirmButtonHorizontalMargin),
            confirmButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.confirmButtonSize),
            confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.confirmButtonVerticalMargin)
        ])
    }
    
    private func setUpCollection() {
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Edition Menu Collection Container"
        collectionContainer.clipsToBounds = false
        
        addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        let trailingMargin = EditorViewConstants.confirmButtonHorizontalMargin * 2 + EditorViewConstants.confirmButtonSize
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -trailingMargin),
            collectionContainer.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor),
            collectionContainer.heightAnchor.constraint(equalToConstant: EditionMenuCollectionView.height)
        ])
    }
    
    // MARK: - buttons
    @objc private func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }
    
    @objc private func closeMenuButtonPressed() {
        
    }
    
    @objc private func confirmButtonPressed() {
        delegate?.confirmButtonPressed()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.confirmButton.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the button to close a menu (checkmark)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseMenuButton(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.closeMenuButton.alpha = show ? 1 : 0
        }
    }
}
