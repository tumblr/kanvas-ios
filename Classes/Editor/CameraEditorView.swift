//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// protocol for closing the preview or confirming

protocol CameraEditorViewDelegate: class {
    /// A function that is called when the confirm button is pressed
    func confirmButtonPressed()
    /// A function that is called when the close button is pressed
    func closeButtonPressed()
    /// A function that is called when the button to close a menu is pressed
    func closeMenuButtonPressed()
}

/// Constants for CameraEditorView
private struct CameraEditorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    static let confirmButtonSize: CGFloat = 49
    static let confirmButtonHorizontalMargin: CGFloat = 20
    static let confirmButtonVerticalMargin: CGFloat = Device.belongsToIPhoneXGroup ? 14 : 19.5
    static let closeMenuButtonSize: CGFloat = 36
    static let closeMenuButtonHorizontalMargin: CGFloat = 20
    static let circleCornerRadius: CGFloat = 27.5
    static let circleSize: CGFloat = 55
    static let circleBorderWidth: CGFloat = 3
}

/// A UIView to preview the contents of segments without exporting

final class CameraEditorView: UIView {
    
    private let imageView: UIImageView = UIImageView()
    private let firstPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    private let secondPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    
    private let confirmButton = UIButton()
    private let closeMenuButton = UIButton()
    private let closeButton = UIButton()
    private let filterSelectionCircle = UIImageView()
    let collectionContainer = IgnoreTouchesView()
    let filterCollectionContainer = IgnoreTouchesView()
    
    private var disposables: [NSKeyValueObservation] = []
    weak var delegate: CameraEditorViewDelegate?
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.add(into: self)
        
        imageView.layer.addSublayer(firstPlayerLayer)
        imageView.layer.addSublayer(secondPlayerLayer)
        
        firstPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        secondPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        performLayerActionsWithoutAnimation {
            firstPlayerLayer.opacity = 0
            secondPlayerLayer.opacity = 0
        }
        
        disposables.append(observe(\.bounds, options: [], changeHandler: { (editorView, _) in
            performUIUpdate {
                editorView.firstPlayerLayer.frame = editorView.bounds
                editorView.secondPlayerLayer.frame = editorView.bounds
            }
        }))
        
        setUpCloseButton()
        setUpCloseMenuButton()
        setUpConfirmButton()
        setUpCollection()
        setUpFilterCollection()
        setUpFilterSelectionCircle()
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
            closeMenuButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -CameraEditorViewConstants.closeMenuButtonHorizontalMargin),
            closeMenuButton.heightAnchor.constraint(equalToConstant: CameraEditorViewConstants.closeMenuButtonSize),
            closeMenuButton.widthAnchor.constraint(equalToConstant: CameraEditorViewConstants.closeMenuButtonSize),
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
            confirmButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -CameraEditorViewConstants.confirmButtonHorizontalMargin),
            confirmButton.heightAnchor.constraint(equalToConstant: CameraEditorViewConstants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: CameraEditorViewConstants.confirmButtonSize),
            confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -CameraEditorViewConstants.confirmButtonVerticalMargin)
        ])
    }
    
    private func setUpCollection() {
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Edition Menu Collection Container"
        collectionContainer.clipsToBounds = false
        
        addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        let trailingMargin = CameraEditorViewConstants.confirmButtonHorizontalMargin * 2 + CameraEditorViewConstants.confirmButtonSize
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -trailingMargin),
            collectionContainer.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor),
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
            filterCollectionContainer.heightAnchor.constraint(equalToConstant: FilterSmallCollectionView.height)
        ])
    }
    
    func setUpFilterSelectionCircle() {
        filterSelectionCircle.accessibilityIdentifier = "Edition Filter Selection Circle"
        filterSelectionCircle.clipsToBounds = false
        filterSelectionCircle.layer.cornerRadius = CameraEditorViewConstants.circleCornerRadius
        filterSelectionCircle.layer.borderWidth = CameraEditorViewConstants.circleBorderWidth
        filterSelectionCircle.layer.borderColor = UIColor.white.cgColor
        filterSelectionCircle.alpha = 0
        
        addSubview(filterSelectionCircle)
        filterSelectionCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterSelectionCircle.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: FilterSmallCollectionController.leftInset + FilterSmallCollectionCell.cellPadding),
            filterSelectionCircle.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor),
            filterSelectionCircle.heightAnchor.constraint(equalToConstant: CameraEditorViewConstants.circleSize),
            filterSelectionCircle.widthAnchor.constraint(equalToConstant: CameraEditorViewConstants.circleSize)
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
    
    // MARK: - internal methods
    
    /// Binds the AVPlayer to the first player layer
    ///
    /// - Parameter player: The player to bind. Can be nil
    func setFirstPlayer(player: AVPlayer?) {
        firstPlayerLayer.player = player
    }
    
    /// Binds the AVPlayer to the second player layer
    ///
    /// - Parameter player: The player to bind, can be nil
    func setSecondPlayer(player: AVPlayer?) {
        secondPlayerLayer.player = player
    }
    
    /// Sets the image for the ImageView
    ///
    /// - Parameter image: the image to display
    func setImage(image: UIImage) {
        imageView.image = image
        performLayerActionsWithoutAnimation {
            firstPlayerLayer.opacity = 0
            secondPlayerLayer.opacity = 0
        }
    }
    
    /// Shows the first player layer and hides the second
    func showFirstPlayer() {
        performLayerActionsWithoutAnimation {
            firstPlayerLayer.opacity = 1
            secondPlayerLayer.opacity = 0
        }
    }
    
    /// Shows the second player layer and hides the first
    func showSecondPlayer() {
        performLayerActionsWithoutAnimation {
            firstPlayerLayer.opacity = 0
            secondPlayerLayer.opacity = 1
        }
    }
    
    // MARK: - layer helper
    
    /// changing values on a layer has implicit animations, unless you explicitly disable them
    private func performLayerActionsWithoutAnimation(_ action:() -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        action()
        CATransaction.commit()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        UIView.animate(withDuration: CameraEditorViewConstants.animationDuration) {
            self.confirmButton.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the button to close a menu (checkmark)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseMenuButton(_ show: Bool) {
        UIView.animate(withDuration: CameraEditorViewConstants.animationDuration) {
            self.closeMenuButton.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the close button (back caret)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseButton(_ show: Bool) {
        UIView.animate(withDuration: CameraEditorViewConstants.animationDuration) {
            self.closeButton.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the filter selection circle
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectionCircle(_ show: Bool) {
        UIView.animate(withDuration: CameraEditorViewConstants.animationDuration) {
            self.filterSelectionCircle.alpha = show ? 1 : 0
        }
    }
}
