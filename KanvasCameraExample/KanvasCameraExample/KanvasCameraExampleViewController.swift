//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import KanvasCamera
import Photos
import UIKit

/// This class contains a button that launches the camera module
/// It is also the delegate for the camera, and handles saving the exported media
/// The camera can be customized with CameraSettings
final class KanvasCameraExampleViewController: UIViewController {

    private let button = UIButton(type: .custom)
    private var shouldShowWelcomeTooltip = true
    private var firstLaunch = true

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(button)

        setupButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        launchCameraFirstTime()
    }

    @objc private func cameraSelected() {
        launchCamera(animated: true)
    }

    private func launchCameraFirstTime() {
        if firstLaunch {
            firstLaunch = false
            launchCamera(animated: false)

            button.addTarget(self, action: #selector(cameraSelected), for: .touchUpInside)
        }
    }

    private func launchCamera(animated: Bool = true) {
        let settings = customCameraSettings()
        let controller = CameraController(settings: settings, analyticsProvider: KanvasCameraAnalyticsStub())
        controller.delegate = self
        self.present(controller, animated: animated, completion: nil)
    }

    private func setupButton() {
        button.isUserInteractionEnabled = false

        // layout
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // background
        button.setBackgroundImage(UIImage(color: .white), for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor(hex: 0xEEEEEE)), for: .highlighted)

        // title
        button.setTitle("Loading...", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.titleLabel?.font = UIFont.favoritTumblr85(fontSize: 18)
    }

    private func resetButton() {
        button.isUserInteractionEnabled = true

        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true

        button.setTitle("Start camera", for: .normal)
    }

    /// This returns the customized settings for the CameraController
    ///
    /// - Returns: an instance of CameraSettings
    private func customCameraSettings() -> CameraSettings {
        let settings = CameraSettings()
        settings.enabledModes = [.photo, .gif, .stopMotion]
        settings.defaultMode = .stopMotion
        settings.exportStopMotionPhotoAsVideo = true
        settings.features.ghostFrame = true
        settings.features.openGLPreview = true
        settings.features.openGLCapture = true
        settings.features.cameraFilters = true
        settings.features.editor = false
        settings.features.editorFilters = true
        settings.features.editorMedia = true
        return settings
    }

}

// MARK: - CameraControllerDelegate

extension KanvasCameraExampleViewController: CameraControllerDelegate {

    func cameraShouldShowWelcomeTooltip() -> Bool {
        return shouldShowWelcomeTooltip
    }

    func didDismissWelcomeTooltip() {
        shouldShowWelcomeTooltip = false
    }

    func didCreateMedia(media: KanvasCameraMedia?, error: Error?) {
        if let media = media {
            save(media: media)
        }
        else {
            assertionFailure("Failed to create media")
        }
        dismissCamera()
    }

    func dismissButtonPressed() {
        dismissCamera()
    }

    private func save(media: KanvasCameraMedia) {
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                print("Photo Library Authorization: Not Determined... not saving!!")
                return
            case .restricted:
                print("Photo Library Authorization: Restricted... not saving!!")
                return
            case .denied:
                print("Photo Library Authorization: Denied... not saving!!")
                return
            case .authorized:
                print("Photo Library Authorization: Authorized")
            }
        }
        switch media {
        case let .image(url):
            moveToLibrary(url: url, resourceType: .photo)
        case let .video(url):
            moveToLibrary(url: url, resourceType: .video)
        }
    }

    private func moveToLibrary(url: URL, resourceType: PHAssetResourceType) {
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            req.addResource(with: resourceType, fileURL: url, options: options)
        }) { (success, error) in
            guard success else {
                guard let err = error else {
                    assertionFailure("Neigher a success or failure!")
                    return
                }
                print("\(err)")
                return
            }
        }
    }

    private func dismissCamera() {
        resetButton()
        dismiss(animated: true, completion: .none)
    }
}
