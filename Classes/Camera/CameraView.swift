//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Protocol for handling CameraView's interaction.
protocol CameraViewDelegate: ActionsViewDelegate {
    /// A function that is called when the close button is pressed
    func closeButtonPressed()
}

internal struct CameraConstants {
    static let ButtonSize: CGFloat = 34
    static let ButtonMargin: CGFloat = 32
    fileprivate static let HidingAnimationDuration: CGFloat = 0.2
}

/// View with containers for all camera subviews (input, mode selector, etc)
/// that handles their relative layout.
final class CameraView: UIView {

    /// the container for the camera input view
    let cameraInputViewContainer: UIView
    
    /// the container for the camera mode button and the shoot button
    let modeAndShootContainer: UIView
    
    /// the container for the media clips collection view
    let clipsContainer: UIView
    
    /// the container for the next / undo action buttons
    let bottomActionsView: ActionsView
    
    /// the container for the options (flash, flip camera)
    let topOptionsContainer: UIView

    private let closeButton: UIButton

    weak var delegate: CameraViewDelegate? {
        didSet {
            bottomActionsView.delegate = delegate
        }
    }

    init() {
        // Base views
        cameraInputViewContainer = UIView()

        // Main views
        closeButton = UIButton()
        topOptionsContainer = IgnoreTouchesView()
        modeAndShootContainer = IgnoreTouchesView()
        clipsContainer = IgnoreTouchesView()
        bottomActionsView = ActionsView()

        // Overlays
        
        super.init(frame: .zero)

        backgroundColor = .black
        setUpViews()
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the UI depending on whether recording is enabled
    ///
    /// - Parameter isRecording: if the UI should reflect that the user is currently recording
    func updateUI(forRecording isRecording: Bool) {
        let views = [bottomActionsView, clipsContainer, closeButton, topOptionsContainer]
        if isRecording {
            showViews(shownViews: [], hiddenViews: views, animated: true)
        } else {
            showViews(shownViews: views, hiddenViews: [], animated: true)
        }
    }

    // MARK: - Layout

    private func setUpViews() {
        // First add them all to hierarchy so constraints don't fail when created.
        // Also add them in order so that the correct ones are on top of the others.
        addSubviewsInOrder()

        // Base views
        setUpInputContainer()

        // Main views
        setUpTopOptionsContainer()
        setUpModeContainer()
        setUpClipsContainer()
        setUpActionsContainer()
        setUpCloseButton()
    }

    private func addSubviewsInOrder() {
        let orderedViews = [cameraInputViewContainer,
                            closeButton,
                            topOptionsContainer,
                            modeAndShootContainer,
                            clipsContainer,
                            bottomActionsView]
        orderedViews.forEach { view in
            addSubview(view)
        }
    }

    private func setUpInputContainer() {
        cameraInputViewContainer.backgroundColor = .black
        cameraInputViewContainer.accessibilityIdentifier = "Media Content Container"
        cameraInputViewContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraInputViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraInputViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraInputViewContainer.topAnchor.constraint(equalTo: topAnchor),
            cameraInputViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setUpModeContainer() {
        modeAndShootContainer.backgroundColor = .clear
        modeAndShootContainer.accessibilityIdentifier = "Mode Selector and Shoot Button Container"
        modeAndShootContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeAndShootContainer.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            modeAndShootContainer.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            modeAndShootContainer.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
            modeAndShootContainer.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor)
        ])
    }

    private func setUpClipsContainer() {
        clipsContainer.backgroundColor = .clear
        clipsContainer.accessibilityIdentifier = "Captured media Clips Container"
        clipsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipsContainer.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            clipsContainer.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            clipsContainer.bottomAnchor.constraint(equalTo: modeAndShootContainer.safeLayoutGuide.bottomAnchor, constant: -ModeSelectorAndShootView.shootButtonTopMargin),
            clipsContainer.heightAnchor.constraint(equalToConstant: MediaClipsEditorView.height)
        ])
    }

    private func setUpActionsContainer() {
        bottomActionsView.backgroundColor = .clear
        bottomActionsView.accessibilityIdentifier = "Bottom Actions Container"
        bottomActionsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomActionsView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            bottomActionsView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            bottomActionsView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -ModeSelectorAndShootView.shootButtonBottomMargin),
            bottomActionsView.heightAnchor.constraint(equalToConstant: ModeSelectorAndShootView.shootButtonSize)
        ])
    }

    private func setUpCloseButton() {
        closeButton.accessibilityLabel = "Close Button"
        closeButton.applyShadows()
        closeButton.setImage(KanvasCameraImages.CloseImage, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: CameraConstants.ButtonMargin),
            closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.ButtonMargin),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: CameraConstants.ButtonSize)
        ])
    }

    private func setUpTopOptionsContainer() {
        topOptionsContainer.backgroundColor = .clear
        topOptionsContainer.accessibilityIdentifier = "Top Options Container"
        topOptionsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topOptionsContainer.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -CameraConstants.ButtonMargin),
            topOptionsContainer.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.ButtonMargin),
            topOptionsContainer.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: CameraConstants.ButtonMargin),
            topOptionsContainer.heightAnchor.constraint(equalToConstant: CameraConstants.ButtonSize)
        ])
    }

    // MARK: - UIButton

    @objc private func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }
    
}
