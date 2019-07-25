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
    /// A function that is called when the post button is pressed
    func postButtonPressed()
}

/// Constants for EditorView
private struct EditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let confirmButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
    static let closeMenuButtonSize: CGFloat = 36
    static let closeMenuButtonHorizontalMargin: CGFloat = 20
    static let circleCornerRadius: CGFloat = 27.5
    static let circleSize: CGFloat = 55
    static let circleBorderWidth: CGFloat = 3
    static let collectionViewHeight = CameraFilterCollectionCell.minimumHeight + 10
    static let postButtonSize: CGFloat = 49
    static let postButtonHorizontalMargin: CGFloat = 20
    static let postButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
}

/// A UIView to preview the contents of segments without exporting

final class EditorView: UIView {

    enum MainActionMode {
        case confirm
        case post
    }
    
    weak var playerView: GLPlayerView?

    private let mainActionMode: MainActionMode
    private let confirmButton = UIButton()
    private let closeMenuButton = UIButton()
    private let closeButton = UIButton()
    private let postButton = UIButton()
    private let filterSelectionCircle = UIImageView()
    let collectionContainer = IgnoreTouchesView()
    let filterCollectionContainer = IgnoreTouchesView()
    let drawingMenuContainer = IgnoreTouchesView()
    
    weak var delegate: EditorViewDelegate?
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(mainActionMode: MainActionMode) {
        self.mainActionMode = mainActionMode
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setupPlayer()
        setUpCloseButton()
        setUpCloseMenuButton()
        switch mainActionMode {
        case .confirm:
            setUpConfirmButton()
        case .post:
            setupPostButton()
        }
        setUpCollection()
        setUpFilterCollection()
        setUpFilterSelectionCircle()
        setUpDrawingMenu()
    }
    
    // MARK: - views

    private func setupPlayer() {
        let playerView = GLPlayerView()
        playerView.add(into: self)
        self.playerView = playerView
    }
    
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
        closeMenuButton.setImage(KanvasCameraImages.editorConfirmImage, for: .normal)
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
            collectionContainer.centerYAnchor.constraint(equalTo: confirmOrPostButton().centerYAnchor),
            collectionContainer.heightAnchor.constraint(equalToConstant: EditionMenuCollectionView.height)
        ])
    }
    
    func setUpFilterCollection() {
        filterCollectionContainer.backgroundColor = .clear
        filterCollectionContainer.accessibilityIdentifier = "Edition Filter Collection Container"
        filterCollectionContainer.clipsToBounds = false
        
        addSubview(filterCollectionContainer)
        filterCollectionContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterCollectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            filterCollectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            filterCollectionContainer.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor),
            filterCollectionContainer.heightAnchor.constraint(equalToConstant: EditorViewConstants.collectionViewHeight)
        ])
    }
    
    func setUpFilterSelectionCircle() {
        filterSelectionCircle.accessibilityIdentifier = "Edition Filter Selection Circle"
        filterSelectionCircle.clipsToBounds = false
        filterSelectionCircle.layer.cornerRadius = EditorViewConstants.circleCornerRadius
        filterSelectionCircle.layer.borderWidth = EditorViewConstants.circleBorderWidth
        filterSelectionCircle.layer.borderColor = UIColor.white.cgColor
        filterSelectionCircle.alpha = 0
        
        addSubview(filterSelectionCircle)
        filterSelectionCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterSelectionCircle.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: EditorFilterCollectionController.leftInset + EditorFilterCollectionCell.cellPadding),
            filterSelectionCircle.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor),
            filterSelectionCircle.heightAnchor.constraint(equalToConstant: EditorViewConstants.circleSize),
            filterSelectionCircle.widthAnchor.constraint(equalToConstant: EditorViewConstants.circleSize)
        ])
    }

    func setupPostButton() {
        postButton.accessibilityLabel = "Post Button"
        postButton.clipsToBounds = false
        postButton.layer.cornerRadius = EditorViewConstants.postButtonSize / 2.0
        postButton.layer.borderWidth = 3.0
        postButton.layer.borderColor = UIColor.white.cgColor
        postButton.applyShadows()
        addSubview(postButton)
        postButton.setImage(KanvasCameraImages.postImage, for: .normal)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        postButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            postButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -EditorViewConstants.postButtonHorizontalMargin),
            postButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.postButtonSize),
            postButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.postButtonSize),
            postButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -EditorViewConstants.postButtonVerticalMargin)
        ])
    }

    func confirmOrPostButton() -> UIButton {
        switch mainActionMode {
        case .confirm:
            return confirmButton
        case .post:
            return postButton
        }
    }
    
    private func setUpDrawingMenu() {
        drawingMenuContainer.backgroundColor = .clear
        drawingMenuContainer.accessibilityIdentifier = "Drawing Menu Container"
        drawingMenuContainer.clipsToBounds = false
        
        addSubview(drawingMenuContainer)
        drawingMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawingMenuContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            drawingMenuContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            drawingMenuContainer.topAnchor.constraint(equalTo: topAnchor),
            drawingMenuContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - buttons
    @objc private func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }
    
    @objc private func closeMenuButtonPressed() {
        delegate?.closeMenuButtonPressed()
    }
    
    @objc private func confirmButtonPressed() {
        delegate?.confirmButtonPressed()
    }

    @objc private func postButtonPressed() {
        delegate?.postButtonPressed()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        switch mainActionMode {
        case .confirm:
            UIView.animate(withDuration: EditorViewConstants.animationDuration) {
                self.confirmButton.alpha = show ? 1 : 0
            }
        case .post:
            UIView.animate(withDuration: EditorViewConstants.animationDuration) {
                self.postButton.alpha = show ? 1 : 0
            }
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
    
    /// shows or hides the close button (back caret)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseButton(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.closeButton.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the filter selection circle
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectionCircle(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.filterSelectionCircle.alpha = show ? 1 : 0
        }
    }
}
