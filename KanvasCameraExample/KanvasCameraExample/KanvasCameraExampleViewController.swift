//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import KanvasCamera
import Photos
import UIKit
import Utils

private enum PhotoLibraryAccessError: Error {
    case notDetermined, restricted, denied, move(Error)
}

/// This class contains a button that launches the camera module
/// It is also the delegate for the camera, and handles saving the exported media
/// The camera can be customized with CameraSettings
final class KanvasCameraExampleViewController: UIViewController {

    private struct Constants {
        static let standardModes: Set<CameraMode> = [.photo, .loop, .stopMotion]
        static let newModes: Set<CameraMode> = [.gif, .normal, .stitch]
        static let defaultStandardMode: CameraMode = .stopMotion
        static let defaultNewMode: CameraMode = .normal
    }

    private let launchKanvasButton = UIButton(type: .custom)
    private let launchKanvasDashboardButton = UIButton(type: .system)
    private var shouldShowWelcomeTooltip = true
    private var shouldShowColorSelectorTooltip = true
    private var shouldShowStrokeSelectorAnimation = true
    private var firstLaunch = true
    private lazy var featuresTable: FeatureTableView = {
        let featureTableView = FeatureTableView(frame: .zero)
        featureTableView.delegate = self
        return featureTableView
    }()
    private var settings: CameraSettings = KanvasCameraExampleViewController.customCameraSettings()
    private var cameraSettings: CameraSettings {
        settings.exportStopMotionPhotoAsVideo = true
        settings.topButtonsSwapped = false
        settings.crossIconInEditor = false
        settings.showTagButtonInEditor = false
        return settings
    }
    private var dashboardSettings: CameraSettings {
        settings.exportStopMotionPhotoAsVideo = false
        settings.topButtonsSwapped = true
        settings.crossIconInEditor = true
        settings.showTagButtonInEditor = true
        return settings
    }

    private let backgroundColorNormal: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemBackground
        }
        else {
            return .white
        }
    }()

    private let backgroundColorHighlighted: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemGray6
        }
        else {
            return UIColor(hex: 0xEEEEEE)
        }
    }()

    private let labelColor: UIColor = {
        if #available(iOS 13.0, *) {
            return .label
        }
        else {
            return .black
        }
    }()

    private let labelColorHighlighted: UIColor = {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        }
        else {
            return .gray
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColorNormal
        view.addSubview(launchKanvasButton)
        view.addSubview(launchKanvasDashboardButton)
        view.addSubview(featuresTable)

        setupLaunchKanvasButton()
        setupLaunchKanvasDashboardButton()
        setupFeaturesTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstLaunch = false
        showFeaturesTableAfterFirstTime()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetButton()
        launchCameraFirstTime()
    }

    @objc private func launchKanvasButtonTapped() {
        launchCamera(animated: true)
    }

    @objc private func launchKanvasDashboardTapped() {
        let controller = SplitViewController(settings: dashboardSettings)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: .none)
    }

    /// This returns the customized settings for the CameraController
    ///
    /// - Returns: an instance of CameraSettings
    private static func customCameraSettings() -> CameraSettings {
        let settings = CameraSettings()
        settings.features.ghostFrame = true
        settings.features.openGLPreview = true
        settings.features.openGLCapture = true
        settings.features.cameraFilters = true
        settings.features.editor = true
        settings.features.editorGif = true
        settings.features.editorGifToggle = true
        settings.features.editorFilters = true
        settings.features.editorText = true
        settings.features.editorMedia = true
        settings.features.editorDrawing = true
        settings.features.mediaPicking = true
        settings.features.editorPosting = true
        settings.features.editorSaving = true
        settings.features.editorPostOptions = false
        settings.features.newCameraModes = true
        settings.enabledModes = settings.features.newCameraModes ? Constants.newModes : Constants.standardModes
        settings.defaultMode = settings.features.newCameraModes ? Constants.defaultNewMode : Constants.defaultStandardMode
        return settings
    }

    private func launchCameraFirstTime() {
        if firstLaunch {
            firstLaunch = false
            launchCamera(animated: false)
        }
    }

    private func launchCamera(animated: Bool = true) {
        let controller = CameraController(settings: cameraSettings, stickerProvider: ExperimentalStickerProvider(), analyticsProvider: KanvasCameraAnalyticsStub(), quickBlogSelectorCoordinator: nil)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: animated, completion: nil)
    }

    private func setupLaunchKanvasButton() {
        launchKanvasButton.isUserInteractionEnabled = false

        // layout
        let buttonOffset: CGFloat = KanvasDevice.belongsToIPhoneXGroup ? 95 : 101
        let buttonWidth: CGFloat = 90
        launchKanvasButton.translatesAutoresizingMaskIntoConstraints = false
        launchKanvasButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        launchKanvasButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -buttonOffset).isActive = true
        launchKanvasButton.widthAnchor.constraint(equalTo: launchKanvasButton.heightAnchor).isActive = true
        launchKanvasButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true

        // background
        launchKanvasButton.setBackgroundImage(UIImage(color: backgroundColorNormal), for: .normal)
        launchKanvasButton.setBackgroundImage(UIImage(color: backgroundColorHighlighted), for: .highlighted)

        // title
        launchKanvasButton.setTitle("", for: .normal)
        launchKanvasButton.setTitleColor(labelColor, for: .normal)
        launchKanvasButton.setTitleColor(labelColor, for: .highlighted)
        launchKanvasButton.titleLabel?.font = UIFont.favoritTumblr85(fontSize: 18)

        // action
        launchKanvasButton.addTarget(self, action: #selector(launchKanvasButtonTapped), for: .touchUpInside)
    }

    private func setupLaunchKanvasDashboardButton() {
        launchKanvasDashboardButton.isUserInteractionEnabled = false

        // layout
        launchKanvasDashboardButton.titleLabel?.textAlignment = .center
        launchKanvasDashboardButton.translatesAutoresizingMaskIntoConstraints = false
        launchKanvasDashboardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        launchKanvasDashboardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true

        // text
        launchKanvasDashboardButton.setTitle("", for: .normal)
        launchKanvasDashboardButton.titleLabel?.font = UIFont.favoritTumblr85(fontSize: 18)
        launchKanvasDashboardButton.titleLabel?.textAlignment = .center
        launchKanvasDashboardButton.setTitleColor(labelColor, for: .normal)
        launchKanvasDashboardButton.setTitleColor(labelColorHighlighted, for: .highlighted)

        // actions
        launchKanvasDashboardButton.addTarget(self, action: #selector(launchKanvasDashboardTapped), for: .touchUpInside)
    }

    private func setupFeaturesTable() {
        // layout
        featuresTable.translatesAutoresizingMaskIntoConstraints = false
        featuresTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        featuresTable.bottomAnchor.constraint(equalTo: launchKanvasButton.topAnchor).isActive = true
        featuresTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        featuresTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        featuresTable.alpha = 0
    }

    private func showFeaturesTableAfterFirstTime() {
        if !firstLaunch {
            featuresTable.alpha = 1
        }
    }

    private func resetButton() {
        launchKanvasButton.isUserInteractionEnabled = true

        launchKanvasButton.layer.borderColor = labelColor.cgColor
        launchKanvasButton.layer.borderWidth = 3
        launchKanvasButton.layer.cornerRadius = launchKanvasButton.bounds.width / 2
        launchKanvasButton.layer.masksToBounds = true

        launchKanvasButton.setTitle("Start", for: .normal)
        
        launchKanvasDashboardButton.isUserInteractionEnabled = true
        launchKanvasDashboardButton.setTitle("Open Kanvas Dashboard", for: .normal)
        launchKanvasDashboardButton.sizeToFit()
    }

}

// MARK: - FeaturesTableViewDelegate

extension KanvasCameraExampleViewController: FeatureTableViewDelegate {
    func featureTableViewLoadFeatures() -> [FeatureTableView.KanvasFeature] {
        return [
            .ghostFrame(settings.features.ghostFrame),
            .openGLPreview(settings.features.openGLPreview),
            .openGLCapture(settings.features.openGLCapture),
            .cameraFilters(settings.features.cameraFilters),
            .experimentalCameraFilters(settings.features.experimentalCameraFilters),
            .editor(settings.features.editor),
            .editorGif(settings.features.editorGif),
            .editorGifToggle(settings.features.editorGifToggle),
            .editorFilters(settings.features.editorFilters),
            .editorText(settings.features.editorText),
            .editorMedia(settings.features.editorMedia),
            .editorDrawing(settings.features.editorDrawing),
            .mediaPicking(settings.features.mediaPicking),
            .editorSaving(settings.features.editorSaving),
            .editorPosting(settings.features.editorPosting),
            .editorPostOptions(settings.features.editorPostOptions),
            .newCameraModes(settings.features.newCameraModes),
        ]
    }

    func featureTableView(didUpdateFeature feature: FeatureTableView.KanvasFeature, withValue value: Bool) {
        switch feature {
        case .ghostFrame(_):
            settings.features.ghostFrame = value
        case .openGLPreview(_):
            settings.features.openGLPreview = value
        case .openGLCapture(_):
            settings.features.openGLCapture = value
        case .cameraFilters(_):
            settings.features.cameraFilters = value
        case .experimentalCameraFilters(_):
            settings.features.experimentalCameraFilters = value
        case .editor(_):
            settings.features.editor = value
        case .editorGif(_):
            settings.features.editorGif = value
        case .editorGifToggle(_):
            settings.features.editorGifToggle = value
        case .editorFilters(_):
            settings.features.editorFilters = value
        case .editorText(_):
            settings.features.editorText = value
        case .editorMedia(_):
            settings.features.editorMedia = value
        case .editorDrawing(_):
            settings.features.editorDrawing = value
        case .mediaPicking(_):
            settings.features.mediaPicking = value
        case .editorPosting(_):
            settings.features.editorPosting = value
        case .editorSaving(_):
            settings.features.editorSaving = value
        case .newCameraModes(_):
            settings.features.newCameraModes = value
            settings.enabledModes = settings.features.newCameraModes ? Constants.newModes : Constants.standardModes
            settings.defaultMode = settings.features.newCameraModes ? Constants.defaultNewMode : Constants.defaultStandardMode
        case .editorPostOptions(_):
            settings.features.editorPostOptions = value
        }
    }
}

// MARK: - CameraControllerDelegate

extension KanvasCameraExampleViewController: CameraControllerDelegate {

    func openAppSettings(completion: ((Bool) -> ())?) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        }
    }

    func tagButtonPressed() {
        // Only supported in Orangina
    }

    func editorDismissed() {
        // Only supported in Orangina
    }

    func cameraShouldShowWelcomeTooltip() -> Bool {
        return shouldShowWelcomeTooltip
    }

    func didDismissWelcomeTooltip() {
        shouldShowWelcomeTooltip = false
    }
    
    func editorShouldShowColorSelectorTooltip() -> Bool {
        return shouldShowColorSelectorTooltip
    }
    
    func didDismissColorSelectorTooltip() {
        shouldShowColorSelectorTooltip = false
    }
    
    func didEndStrokeSelectorAnimation() {
        shouldShowStrokeSelectorAnimation = false
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        return shouldShowStrokeSelectorAnimation
    }

    func didBeginDragInteraction() {
        
    }
    
    func didEndDragInteraction() {
        
    }
    
    func didCreateMedia(_ cameraController: CameraController, media: KanvasCameraMedia?, exportAction: KanvasExportAction, error: Error?) {
        if let error = error {
            assertionFailure("Error creating Kanvas media: \(error)")
            return
        }
        guard let media = media else {
            assertionFailure("No error, but no media!?")
            return
        }

        save(media: media) { err in
            DispatchQueue.main.async {
                if TARGET_OS_SIMULATOR == 0 {
                    guard err == nil else {
                        assertionFailure("Error saving to photo library")
                        return
                    }
                }

                switch exportAction {
                case .previewConfirm:
                    self.dismissCamera()
                case .confirm:
                    self.dismissCamera()
                case .post:
                    self.dismissCamera()
                case .save:
                    break
                case .postOptions:
                    self.dismissCamera()
                }

            }
        }
    }

    func dismissButtonPressed(_ cameraController: CameraController) {
        dismissCamera()
    }

    func provideMediaPickerThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // Providing nil signals CameraController to load the thumbnail itself
        completion(nil)
    }

    private func save(media: KanvasCameraMedia, completion: @escaping (Error?) -> ()) {
        let completionMainThread: (Error?) -> () = { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                completionMainThread(PhotoLibraryAccessError.notDetermined)
            case .restricted:
                completionMainThread(PhotoLibraryAccessError.restricted)
            case .denied:
                completionMainThread(PhotoLibraryAccessError.denied)
            case .authorized:
                switch media {
                case let .image(url, _, _):
                    self.moveToLibrary(url: url, resourceType: .photo, completion: completionMainThread)
                case let .video(url, _, _):
                    self.moveToLibrary(url: url, resourceType: .video, completion: completionMainThread)
                }
            }
        }

    }

    private func moveToLibrary(url: URL, resourceType: PHAssetResourceType, completion: @escaping (Error?) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            req.addResource(with: resourceType, fileURL: url, options: options)
        }, completionHandler: { (success, error) in
            if let error = error {
                completion(PhotoLibraryAccessError.move(error))
            }
            else {
                completion(nil)
            }
        })
    }

    private func dismissCamera() {
        resetButton()
        dismiss(animated: true, completion: .none)
    }
}
