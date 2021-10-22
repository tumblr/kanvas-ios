//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// protocol for closing the preview or confirming

protocol CameraPreviewViewDelegate: class {
    /// A function that is called when the confirm button is pressed
    func confirmButtonPressed()
    /// A function that is called when the close button is pressed
    func closeButtonPressed()
}

/// Constants for CameraPreviewView
private struct CameraPreviewViewConstants {
    static let confirmButtonSize: CGFloat = 54
    static let confirmButtonMargin: CGFloat = 64
}

/// A UIView to preview the contents of segments without exporting

final class CameraPreviewView: UIView {

    private let imageView: UIImageView = UIImageView()
    private let firstPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    private let secondPlayerLayer: AVPlayerLayer = AVPlayerLayer()

    private let confirmButton = UIButton()
    private let closeButton = UIButton()

    private var disposables: [NSKeyValueObservation] = []
    weak var delegate: CameraPreviewViewDelegate?

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

        disposables.append(observe(\.bounds, options: [], changeHandler: { (previewView, _) in
            performUIUpdate {
                previewView.firstPlayerLayer.frame = previewView.bounds
                previewView.secondPlayerLayer.frame = previewView.bounds
            }
        }))

        setUpCloseButton()
        setUpConfirmButton()
    }
    
    // MARK: - views

    private func setUpCloseButton() {
        closeButton.accessibilityLabel = "Close Button"
        closeButton.layer.applyShadows(offset: CGSize(width: 0.0, height: 2.0), radius: 0.0)
        closeButton.setImage(KanvasImages.backImage, for: .normal)
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
        confirmButton.layer.applyShadows(offset: CGSize(width: 0.0, height: 2.0), radius: 0.0)
        addSubview(confirmButton)

        confirmButton.setBackgroundImage(KanvasImages.circleImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        confirmButton.setImage(KanvasImages.shared.confirmImage, for: .normal)
        confirmButton.tintColor = KanvasColors.shared.cameraConfirmationColor
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            confirmButton.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -CameraPreviewViewConstants.confirmButtonMargin),
            confirmButton.heightAnchor.constraint(equalTo: confirmButton.widthAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: CameraPreviewViewConstants.confirmButtonSize)
        ])
    }
    
    // MARK: - buttons
    @objc private func closeButtonPressed() {
        delegate?.closeButtonPressed()
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
}
