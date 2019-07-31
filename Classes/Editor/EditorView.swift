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
    func didTapConfirmButton()
    /// A function that is called when the close button is pressed
    func didTapCloseButton()
    /// A function that is called when the post button is pressed
    func didTapPostButton()
    /// A function that is called when the save button is pressed
    func didTapSaveButton()
}

/// Constants for EditorView
private struct EditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let confirmButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
    static let postButtonSize: CGFloat = 49
    static let postButtonHorizontalMargin: CGFloat = 20
    static let postButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
    static let saveButtonSize: CGFloat = 34
    static let saveButtonHorizontalMargin: CGFloat = 20
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
    private let closeButton = UIButton()
    private let saveButton = UIButton()
    private let showSaveButton: Bool
    private let postButton = UIButton()
    private let filterSelectionCircle = UIImageView()
    let collectionContainer = IgnoreTouchesView()
    let filterMenuContainer = IgnoreTouchesView()
    let drawingMenuContainer = IgnoreTouchesView()
    let drawingCanvas = IgnoreTouchesView()
    
    weak var delegate: EditorViewDelegate?
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(mainActionMode: MainActionMode, showSaveButton: Bool) {
        self.mainActionMode = mainActionMode
        self.showSaveButton = showSaveButton
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setupPlayer()
        drawingCanvas.add(into: self)
        setUpCloseButton()
        setUpConfirmButton()
        switch mainActionMode {
        case .confirm:
            setUpConfirmButton()
        case .post:
            setupPostButton()
        }
        if showSaveButton {
            setupSaveButton()
        }
        setUpCollection()
        setUpFilterMenu()
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
    
    private func setUpFilterMenu() {
        filterMenuContainer.backgroundColor = .clear
        filterMenuContainer.accessibilityIdentifier = "Filter Menu Container"
        filterMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        filterMenuContainer.clipsToBounds = false
        
        addSubview(filterMenuContainer)
        NSLayoutConstraint.activate([
            filterMenuContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterMenuContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterMenuContainer.topAnchor.constraint(equalTo: topAnchor),
            filterMenuContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
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

    func setupSaveButton() {
        saveButton.accessibilityLabel = "Save Button"
        addSubview(saveButton)
        saveButton.applyShadows()
        saveButton.setImage(KanvasCameraImages.saveImage, for: .normal)
        saveButton.imageView?.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: confirmOrPostButton().leadingAnchor, constant: -EditorViewConstants.saveButtonHorizontalMargin),
            saveButton.heightAnchor.constraint(equalToConstant: EditorViewConstants.saveButtonSize),
            saveButton.widthAnchor.constraint(equalToConstant: EditorViewConstants.saveButtonSize),
            saveButton.centerYAnchor.constraint(equalTo: confirmOrPostButton().centerYAnchor)
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
        delegate?.didTapCloseButton()
    }
    
    @objc private func confirmButtonPressed() {
        delegate?.didTapConfirmButton()
    }

    @objc private func saveButtonPressed() {
        delegate?.didTapSaveButton()
    }

    @objc private func postButtonPressed() {
        delegate?.didTapPostButton()
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
        if showSaveButton {
            UIView.animate(withDuration: EditorViewConstants.animationDuration) {
                self.saveButton.alpha = show ? 1 : 0
            }
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
}
