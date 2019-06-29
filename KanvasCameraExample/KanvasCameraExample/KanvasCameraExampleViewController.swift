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

    private struct Constants {
        static let featureCellReuseIdentifier = "featureCell"
    }

    private let button = UIButton(type: .custom)
    private let featuresTable = UITableView(frame: .zero)
    private var shouldShowWelcomeTooltip = true
    private var firstLaunch = true
    private lazy var featuresData: [KanvasFeature] = {
        return buildFeaturesData()
    }()
    private lazy var settings: CameraSettings = {
        return KanvasCameraExampleViewController.customCameraSettings()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(button)
        view.addSubview(featuresTable)

        setupButton()
        setupFeaturesTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showFeaturesTableAfterFirstTime()
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
        let controller = CameraController(settings: settings, analyticsProvider: KanvasCameraAnalyticsStub())
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: animated, completion: nil)
    }

    private func setupButton() {
        button.isUserInteractionEnabled = false

        // layout
        let buttonOffset: CGFloat = KanvasDevice.belongsToIPhoneXGroup ? 95 : 101
        let buttonWidth: CGFloat = 90
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -buttonOffset).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true

        // background
        button.setBackgroundImage(UIImage(color: .white), for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor(hex: 0xEEEEEE)), for: .highlighted)

        // title
        button.setTitle("", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.titleLabel?.font = UIFont.favoritTumblr85(fontSize: 18)
    }

    private func setupFeaturesTable() {
        // layout
        featuresTable.translatesAutoresizingMaskIntoConstraints = false
        featuresTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        featuresTable.bottomAnchor.constraint(equalTo: button.topAnchor).isActive = true
        featuresTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        featuresTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        featuresTable.alpha = 0

        // table view
        featuresTable.delegate = self
        featuresTable.dataSource = self
        featuresTable.register(FeatureTableViewCell.self, forCellReuseIdentifier: Constants.featureCellReuseIdentifier)
    }

    private func showFeaturesTableAfterFirstTime() {
        if !firstLaunch {
            featuresTable.alpha = 1
        }
    }

    private func resetButton() {
        button.isUserInteractionEnabled = true

        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = button.bounds.width / 2
        button.layer.masksToBounds = true

        button.setTitle("Start", for: .normal)
    }

}

// MARK: - Kanvas Features and UITableViewDelegate and UITableViewDataSource

extension KanvasCameraExampleViewController: UITableViewDelegate, UITableViewDataSource, FeatureTableViewCellDelegate {

    /// This returns the customized settings for the CameraController
    ///
    /// - Returns: an instance of CameraSettings
    private static func customCameraSettings() -> CameraSettings {
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
        settings.features.mediaPicking = true
        return settings
    }

    private enum KanvasFeature {
        case ghostFrame(Bool)
        case openGLPreview(Bool)
        case openGLCapture(Bool)
        case cameraFilters(Bool)
        case experimentalCameraFilters(Bool)
        case editor(Bool)
        case editorFilters(Bool)
        case editorMedia(Bool)
        case editorDrawing(Bool)

        var name: String {
            switch self {
            case .ghostFrame(_):
                return "Camera Ghost Frame"
            case .openGLPreview(_):
                return "Camera OpenGL"
            case .openGLCapture(_):
                return "Camera OpenGL Capture"
            case .cameraFilters(_):
                return "Camera Filters"
            case .experimentalCameraFilters(_):
                return "Camera Filters (experimental)"
            case .editor(_):
                return "Editor"
            case .editorFilters(_):
                return "Editor Filters"
            case .editorMedia(_):
                return "Editor Media"
            case .editorDrawing(_):
                return "Editor Drawing"
            }
        }

        var enabled: Bool {
            switch self {
            case .ghostFrame(let enabled):
                return enabled
            case .openGLPreview(let enabled):
                return enabled
            case .openGLCapture(let enabled):
                return enabled
            case .cameraFilters(let enabled):
                return enabled
            case .experimentalCameraFilters(let enabled):
                return enabled
            case .editor(let enabled):
                return enabled
            case .editorFilters(let enabled):
                return enabled
            case .editorMedia(let enabled):
                return enabled
            case .editorDrawing(let enabled):
                return enabled
            }
        }
    }

    private func buildFeaturesData() -> [KanvasFeature] {
        return [
            .ghostFrame(settings.features.ghostFrame),
            .openGLPreview(settings.features.openGLPreview),
            .openGLCapture(settings.features.openGLCapture),
            .cameraFilters(settings.features.cameraFilters),
            .experimentalCameraFilters(settings.features.experimentalCameraFilters),
            .editor(settings.features.editor),
            .editorFilters(settings.features.editorFilters),
            .editorMedia(settings.features.editorMedia),
            .editorDrawing(settings.features.editorDrawing),
        ]
    }

    private func updateFeaturesData(value: Bool, indexPath: IndexPath) {
        switch featuresData[indexPath.row] {
        case .ghostFrame(_):
            featuresData[indexPath.row] = .ghostFrame(value)
            settings.features.ghostFrame = value
        case .openGLPreview(_):
            featuresData[indexPath.row] = .openGLPreview(value)
            settings.features.openGLPreview = value
        case .openGLCapture(_):
            featuresData[indexPath.row] = .openGLCapture(value)
            settings.features.openGLCapture = value
        case .cameraFilters(_):
            featuresData[indexPath.row] = .cameraFilters(value)
            settings.features.cameraFilters = value
        case .experimentalCameraFilters(_):
            featuresData[indexPath.row] = .experimentalCameraFilters(value)
            settings.features.experimentalCameraFilters = value
        case .editor(_):
            featuresData[indexPath.row] = .editor(value)
            settings.features.editor = value
        case .editorFilters(_):
            featuresData[indexPath.row] = .editorFilters(value)
            settings.features.editorFilters = value
        case .editorMedia(_):
            featuresData[indexPath.row] = .editorMedia(value)
            settings.features.editorMedia = value
        case .editorDrawing(_):
            featuresData[indexPath.row] = .editorDrawing(value)
            settings.features.editorDrawing = value
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuresData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.featureCellReuseIdentifier, for: indexPath)
        guard let featureCell = cell as? FeatureTableViewCell else {
            return cell
        }
        featureCell.indexPath = indexPath
        featureCell.delegate = self
        featureCell.textLabel?.text = featuresData[indexPath.row].name
        featureCell.toggleSwitch(featuresData[indexPath.row].enabled, animated: false)
        return featureCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeatureTableViewCell else {
            return
        }
        let newValue = !featuresData[indexPath.row].enabled
        cell.toggleSwitch(newValue, animated: true)
        updateFeaturesData(value: newValue, indexPath: indexPath)
    }

    func featureTableViewCell(didToggle value: Bool, indexPath: IndexPath) {
        updateFeaturesData(value: value, indexPath: indexPath)
    }
}

protocol FeatureTableViewCellDelegate: class {
    func featureTableViewCell(didToggle value: Bool, indexPath: IndexPath)
}

private class FeatureTableViewCell: UITableViewCell {

    private let switchView: UISwitch = UISwitch(frame: .zero)

    var indexPath: IndexPath?

    weak var delegate: FeatureTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        switchView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(switchView)
        switchView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        switchView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        switchView.addTarget(self, action: #selector(switchTouchUpInside), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func switchTouchUpInside() {
        guard let indexPath = indexPath else { return }
        delegate?.featureTableViewCell(didToggle: switchView.isOn, indexPath: indexPath)
    }

    func toggleSwitch(_ value: Bool, animated: Bool) {
        switchView.setOn(value, animated: animated)
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
