//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for handling CameraView's interaction.
protocol CameraViewDelegate: AnyObject {
    /// A function that is called when the close button is pressed
    func closeButtonPressed()
}

struct CameraConstants {
    static let optionVerticalMargin: CGFloat = KanvasDesign.shared.cameraViewOptionVerticalMargin
    static let optionHorizontalMargin: CGFloat = KanvasDesign.shared.cameraViewOptionHorizontalMargin
    static let optionButtonSize: CGFloat = KanvasDesign.shared.cameraViewOptionButtonSize
    static let optionSpacing: CGFloat = KanvasDesign.shared.cameraViewOptionSpacing
    private static let hidingAnimationDuration: CGFloat = 0.2
    fileprivate static let defaultOptionRows: CGFloat = 2
    
    static let buttonBackgroundColor: UIColor = KanvasDesign.shared.cameraViewButtonBackgroundColor
    static let buttonInvertedBackgroundColor: UIColor = KanvasDesign.shared.cameraViewButtonInvertedBackgroundColor
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
    
    /// Layout guide for the filter settings
    private let filterSettingsLayoutGuide = UILayoutGuide()

    /// Layout guide for the camera permissions view
    private let permissionsLayoutGuide = UILayoutGuide()

    /// the container for the camera input view
    private var cameraInputViewContainer: UIView?

    /// the container for the camera mode button and the shoot button
    private var modeAndShootContainer: UIView?

    /// the container for the media clips collection view
    private var clipsContainer: UIView?
    
    /// the container for the fullscreen image preview
    private var imagePreviewViewContainer: UIView?
    
    /// the container for the filter settings view
    private var filterSettingsViewContainer: UIView?

    private var permissionsViewContainer: UIView?
    
    /// the container for the options (flash, flip camera)
    private var topOptionsContainer: UIView?

    private let closeButton: UIButton

    weak var delegate: CameraViewDelegate?

    private let numberOfOptionRows: CGFloat
    private let settings: CameraSettings

    convenience init() {
        self.init(settings: CameraSettings(), numberOfOptionRows: CameraConstants.defaultOptionRows)
    }

    init(settings: CameraSettings, numberOfOptionRows: CGFloat) {
        self.numberOfOptionRows = numberOfOptionRows
        self.settings = settings
        
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
    
    /// Updates the UI depending on whether a clip is being dragged
    ///
    /// - Parameter isDragging: if the UI should reflect that the user is currently dragging a clip
    func updateUI(forDraggingClip isDragging: Bool) {
        let views = [closeButton, topOptionsContainer, filterSettingsViewContainer]
        if isDragging {
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
        setupFilterSettingsGuide()
        setupPermissionsGuide()
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
        
        let bottomMargin: CGFloat = KanvasDesign.shared.isBottomPicker ? MediaClipsEditorView.height - (ModeSelectorAndShootView.modeSelectorHeight + ModeSelectorAndShootView.modeSelectorTopMargin) : MediaClipsEditorView.height
        
        modeLayoutGuide.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor).isActive = true
        modeLayoutGuide.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor).isActive = true
        modeLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomMargin).isActive = true
        modeLayoutGuide.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin).isActive = true
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
        let height = CameraConstants.optionButtonSize * numberOfOptionRows + CameraConstants.optionSpacing * (numberOfOptionRows - 1)
        optionsLayoutGuide.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin).isActive = true
        optionsLayoutGuide.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        if settings.topButtonsSwapped {
            optionsLayoutGuide.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: CameraConstants.optionHorizontalMargin).isActive = true
            optionsLayoutGuide.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -CameraConstants.optionHorizontalMargin).isActive = true
        }
        else {
            optionsLayoutGuide.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: CameraConstants.optionHorizontalMargin).isActive = true
            optionsLayoutGuide.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -CameraConstants.optionHorizontalMargin).isActive = true
        }
    }
    
    private func setupImagePreviewGuide() {
        addLayoutGuide(imagePreviewLayoutGuide)
        imagePreviewLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imagePreviewLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imagePreviewLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imagePreviewLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setupFilterSettingsGuide() {
        let bottomMargin = MediaClipsEditorView.height + ModeSelectorAndShootView.shootButtonBottomMargin + ((ModeSelectorAndShootView.shootButtonSize - FilterSettingsView.collectionViewHeight) / 2)
        
        addLayoutGuide(filterSettingsLayoutGuide)
        filterSettingsLayoutGuide.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor).isActive = true
        filterSettingsLayoutGuide.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor).isActive = true
        filterSettingsLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomMargin).isActive = true
        filterSettingsLayoutGuide.heightAnchor.constraint(equalToConstant: FilterSettingsView.height).isActive = true
    }

    private func setupPermissionsGuide() {
        addLayoutGuide(permissionsLayoutGuide)
        NSLayoutConstraint.activate([
            permissionsLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            permissionsLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            permissionsLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            permissionsLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setUpViews() {
        setUpCloseButton()
    }

    private func setUpCloseButton() {
        addSubview(closeButton)
        closeButton.accessibilityLabel = "Close Button"
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        if KanvasDesign.shared.isBottomPicker {
            closeButton.backgroundColor = CameraConstants.buttonBackgroundColor
            closeButton.layer.cornerRadius = CameraConstants.optionButtonSize / 2
            closeButton.layer.masksToBounds = true
        }
        else {
            closeButton.layer.applyShadows(offset: CGSize(width: 0.0, height: 2.0), radius: 0.0)
            closeButton.imageView?.contentMode = .scaleAspectFit
        }
        
        if settings.topButtonsSwapped {
            closeButton.setImage(KanvasDesign.shared.cameraViewNextImage, for: .normal)
            NSLayoutConstraint.activate([
                closeButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -CameraConstants.optionHorizontalMargin),
                closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin),
                closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize)
            ])
        }
        else {
            closeButton.setImage(KanvasDesign.shared.cameraViewCloseImage, for: .normal)
            
            NSLayoutConstraint.activate([
                closeButton.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: CameraConstants.optionHorizontalMargin),
                closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: CameraConstants.optionVerticalMargin),
                closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: CameraConstants.optionButtonSize)
            ])
        }
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
    /// - Parameter view: view for the filter settings
    func addFiltersView(_ view: UIView) {
        guard filterSettingsViewContainer == nil else { return }
        filterSettingsViewContainer = view
        addViewWithGuide(view: view, guide: filterSettingsLayoutGuide)
    }

    func addPermissionsView(_ view: UIView) {
        guard permissionsViewContainer == nil else { return }
        permissionsViewContainer = view
        addViewWithGuide(view: view, guide: permissionsLayoutGuide)
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
                            topOptionsContainer,
                            filterSettingsViewContainer,
                            modeAndShootContainer,
                            clipsContainer,
                            permissionsViewContainer,
                            closeButton]
        orderedViews.forEach { view in
            if let view = view {
                addSubview(view)
            }
        }
    }

}
