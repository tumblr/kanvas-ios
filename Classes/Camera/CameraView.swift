//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Protocol for handling CameraView's interaction.
protocol CameraViewDelegate: class {
    /// A function that is called when the close button is pressed
    func closeButtonPressed()
}

struct CameraConstants {
    static let buttonSize: CGFloat = 34
    static let buttonMargin: CGFloat = 32
    static let buttonSpacing: CGFloat = 8
    fileprivate static let hidingAnimationDuration: CGFloat = 0.2
    fileprivate static let defaultOptionRows: CGFloat = 2
}

/// View with containers for all camera subviews (input, mode selector, etc)
/// that handles their relative layout.
final class CameraView: UIView {

    /// Layout guide for camera input
    private let cameraInputLayoutGuide = UILayoutGuide()

    /// Layout guide for mode layout
    private let modeLayoutGuide = UILayoutGuide()

    /// Layout guide for clips
    private let clipsLayoutGuide = UILayoutGuide()

    /// Layout guide for options
    private let optionsLayoutGuide = UILayoutGuide()
    
    /// Layout guide for the fullscreen image preview
    private let imagePreviewLayoutGuide = UILayoutGuide()
    
    /// Layout guide for filter settings
    private let filtersLayoutGuide = UILayoutGuide()
    
    /// the container for the camera input view
    private var cameraInputViewContainer: UIView?

    /// the container for the camera mode button and the shoot button
    private var modeAndShootContainer: UIView?

    /// the container for the media clips collection view
    private var clipsContainer: UIView?
    
    /// the container for the fullscreen image preview
    private var imagePreviewViewContainer: UIView?

    /// the container for the filter settings view
    private var filtersViewContainer: UIView?

    /// the container for the options (flash, flip camera)
    private var topOptionsContainer: UIView?

    private let closeButton: UIButton

    weak var delegate: CameraViewDelegate?

    private let numberOfOptionRows: CGFloat

    convenience init() {
        self.init(numberOfOptionRows: CameraConstants.defaultOptionRows)
    }

    init(numberOfOptionRows: CGFloat) {
        self.numberOfOptionRows = numberOfOptionRows

        // Main views
        closeButton = UIButton()

        super.init(frame: .zero)

        backgroundColor = .black
        setUpViews()
        setupLayoutGuides()
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
        let views = [clipsContainer, closeButton, topOptionsContainer]
        if isRecording {
            showViews(shownViews: [], hiddenViews: views, animated: true)
        }
        else {
            showViews(shownViews: views, hiddenViews: [], animated: true)
        }
    }

    // MARK: - Layout
    private func setupLayoutGuides() {
        setupCameraInputGuide()
        setupModeLayoutGuide()
        setupClipsGuide()
        setupOptionsGuide()
        setupImagePreviewGuide()
        setupFiltersGuide()
    }

    private func setupCameraInputGuide() {
        addLayoutGuide(cameraInputLayoutGuide)
        cameraInputLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cameraInputLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        cameraInputLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cameraInputLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setupModeLayoutGuide() {
        addLayoutGuide(modeLayoutGuide)
        modeLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        modeLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        modeLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                constant: -MediaClipsEditorView.height).isActive = true
        modeLayoutGuide.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.buttonMargin).isActive = true
    }

    private func setupClipsGuide() {
        addLayoutGuide(clipsLayoutGuide)
        clipsLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        clipsLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        clipsLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        clipsLayoutGuide.heightAnchor.constraint(equalToConstant: MediaClipsEditorView.height).isActive = true
    }

    private func setupOptionsGuide() {
        addLayoutGuide(optionsLayoutGuide)
        // The height is equal to all the rows of buttons plus the space between them
        let height = CameraConstants.buttonSize * numberOfOptionRows + CameraConstants.buttonSpacing * (numberOfOptionRows - 1)
        optionsLayoutGuide.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -CameraConstants.buttonMargin).isActive = true
        optionsLayoutGuide.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.buttonMargin).isActive = true
        optionsLayoutGuide.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: CameraConstants.buttonMargin).isActive = true
        optionsLayoutGuide.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func setupImagePreviewGuide() {
        addLayoutGuide(imagePreviewLayoutGuide)
        imagePreviewLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imagePreviewLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imagePreviewLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imagePreviewLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setupFiltersGuide() {
        addLayoutGuide(filtersLayoutGuide)
        filtersLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        filtersLayoutGuide.bottomAnchor.constraint(equalTo: modeLayoutGuide.bottomAnchor,
                                                   constant: -ModeSelectorAndShootView.shootButtonTopMargin).isActive = true
        filtersLayoutGuide.heightAnchor.constraint(equalToConstant: FilterView.height).isActive = true
    }
    
    private func setUpViews() {
        setUpCloseButton()
    }

    private func setUpCloseButton() {
        addSubview(closeButton)
        closeButton.accessibilityLabel = "Close Button"
        closeButton.applyShadows()
        closeButton.setImage(KanvasCameraImages.closeImage, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: CameraConstants.buttonMargin),
            closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.buttonMargin),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: CameraConstants.buttonSize)
        ])
    }

    // MARK: - UIButton

    @objc private func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }

    // MARK: - adding subviews

    /// Adds the camera input view
    ///
    /// - Parameter view: view for camera input
    func addCameraInputView(_ view: UIView) {
        guard cameraInputViewContainer == nil else { return }
        cameraInputViewContainer = view
        addViewWithGuide(view: view, guide: cameraInputLayoutGuide)
    }

    /// Adds the mode selector view
    ///
    /// - Parameter view: view for mode selection
    func addModeView(_ view: UIView) {
        guard modeAndShootContainer == nil else { return }
        modeAndShootContainer = view
        addViewWithGuide(view: view, guide: modeLayoutGuide)
    }

    /// Adds the clip editor view
    ///
    /// - Parameter view: view for clip editor
    func addClipsView(_ view: UIView) {
        guard clipsContainer == nil else { return }
        clipsContainer = view
        addViewWithGuide(view: view, guide: clipsLayoutGuide)
    }

    /// Adds the Top Options view
    ///
    /// - Parameter view: view for options
    func addOptionsView(_ view: UIView) {
        guard topOptionsContainer == nil else { return }
        topOptionsContainer = view
        addViewWithGuide(view: view, guide: optionsLayoutGuide)
    }
    
    /// Adds the image preview view
    ///
    /// - Parameter view: view for the image preview
    func addImagePreviewView(_ view: UIView) {
        guard imagePreviewViewContainer == nil else { return }
        imagePreviewViewContainer = view
        addViewWithGuide(view: view, guide: imagePreviewLayoutGuide)
    }
    
    /// Adds the filters view
    ///
    /// - Parameter view: view for the filters settings
    func addFiltersView(_ view: UIView) {
        guard filtersViewContainer == nil else { return }
        filtersViewContainer = view
        addViewWithGuide(view: view, guide: filtersLayoutGuide)
    }
    
    private func addViewWithGuide(view: UIView, guide: UILayoutGuide) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        reorderSubviews()
    }

    private func reorderSubviews() {
        let orderedViews = [cameraInputViewContainer,
                            imagePreviewViewContainer,
                            closeButton,
                            topOptionsContainer,
                            modeAndShootContainer,
                            filtersViewContainer,
                            clipsContainer]
        orderedViews.forEach { view in
            if let view = view {
                addSubview(view)
            }
        }
    }

}
