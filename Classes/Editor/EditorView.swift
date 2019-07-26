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
}

/// Constants for EditorView
private struct EditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let confirmButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
}

/// A UIView to preview the contents of segments without exporting

final class EditorView: UIView {
    
    weak var playerView: GLPlayerView?
    
    private let confirmButton = UIButton()
    private let closeButton = UIButton()
    let collectionContainer = IgnoreTouchesView()
    let filterMenuContainer = IgnoreTouchesView()
    let drawingMenuContainer = IgnoreTouchesView()
    let drawingCanvas = IgnoreTouchesView()
    
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
        drawingCanvas.add(into: self)

        setUpCloseButton()
        setUpConfirmButton()
        setUpCollection()
        setUpFilterMenu()
        setUpDrawingMenu()
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
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        UIView.animate(withDuration: EditorViewConstants.animationDuration) {
            self.confirmButton.alpha = show ? 1 : 0
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
