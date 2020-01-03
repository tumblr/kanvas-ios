//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import SharedUI
import AVFoundation

protocol CaptureDeviceAuthorizing: class {

    func requestAccess(for mediaType: AVMediaType, completionHandler: @escaping (Bool) -> ())

    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus

}

protocol CameraPermissionsViewDelegate: class {

    func cameraAccessButtonPressed()

    func microphoneAccessButtonPressed()

    func mediaPickerButtonPressed()

}

protocol CameraPermissionsViewable: class {

    func updateCameraAccess(hasAccess: Bool)

    func updateMicrophoneAccess(hasAccess: Bool)

    func resetMediaPickerButton()

}

protocol CameraPermissionsViewControllerDelegate: class {

    func cameraPermissionsChanged(hasFullAccess: Bool)

    func didTapMediaPickerButton(completion: (() -> ())?)

    func openAppSettings(completion: ((Bool) -> ())?)
}

class CameraPermissionsView: UIView, CameraPermissionsViewable, MediaPickerButtonViewDelegate {

    private struct Constants {
        static let borderWidth: CGFloat = 2
        static let titleFont: UIFont = .durianMedium()
        static let textColor: UIColor = .white
        static let descriptionFont: UIFont = .guava85()
        static let descriptionOpacity: CGFloat = 0.65
        static let buttonFont: UIFont = .guavaMedium()
        static let buttonColor: UIColor = .init(red: 0, green: 184.0/255.0, blue: 1.0, alpha: 1.0)
        static let buttonAcceptedBackgroundColor: UIColor = .init(hex: 0x00cf35)
        static let buttonAcceptedColor: UIColor = .black
        static let buttonBorderWidth: CGFloat = 1.5
    }

    private lazy var containerView: UIView = {
        let view = UIView().forAutoLayout()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel().forAutoLayout()
        label.text = "Post to Tumblr"
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel().forAutoLayout()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.descriptionFont.pointSize * 0.5
        let attrString = NSMutableAttributedString(string: "Allow access so you can start taking photos and videos")
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))

        label.attributedText = attrString
        label.font = Constants.descriptionFont
        label.textColor = Constants.textColor
        label.alpha = Constants.descriptionOpacity
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var cameraAccessButton: UIButton = {
        let button = CameraPermissionsView.makeButton(title: "Allow access to camera", titleDisabled: "Camera access granted").forAutoLayout()
        button.addTarget(self, action: #selector(cameraAccessButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var microphoneAccessButton: UIButton = {
        let button = CameraPermissionsView.makeButton(title: "Allow access to microphone", titleDisabled: "Microphone access granted").forAutoLayout()
        button.addTarget(self, action: #selector(microphoneAccessButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var mediaPickerButton: MediaPickerButtonView = {
        // TOOD: use actual settings
        let settings = CameraSettings()
        settings.features.mediaPicking = true
        let button = MediaPickerButtonView(settings: settings).forAutoLayout()
        button.delegate = self
        return button
    }()

    private static var checkImage: UIImage = {
        let checkLabel = UILabel()
        checkLabel.font = Constants.buttonFont
        checkLabel.text = "✓"
        checkLabel.textColor = Constants.buttonAcceptedColor
        checkLabel.sizeToFit()
        return checkLabel.asImage()
    }()

    var delegate: CameraPermissionsViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCameraAccess(hasAccess: Bool) {
        cameraAccessButton.isEnabled = !hasAccess
        CameraPermissionsView.updateButton(button: cameraAccessButton)
    }

    func updateMicrophoneAccess(hasAccess: Bool) {
        microphoneAccessButton.isEnabled = !hasAccess
        CameraPermissionsView.updateButton(button: microphoneAccessButton)
    }

    private func setupView() {
        addSubview(containerView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(cameraAccessButton)
        addSubview(microphoneAccessButton)
        addSubview(mediaPickerButton)

        setupContainerView()
        setupTitleView()
        setupDescriptionView()
        setupCameraAccessButton()
        setupMicrophoneAccessButton()
        setupMediaPickerButton()
    }

    private func setupContainerView() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupTitleView() {
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -15),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.60)
        ])
    }

    private func setupDescriptionView() {
        NSLayoutConstraint.activate([
            descriptionLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -25),
            descriptionLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor)
        ])
    }

    private func setupCameraAccessButton() {
        NSLayoutConstraint.activate([
            cameraAccessButton.topAnchor.constraint(equalTo: centerYAnchor),
            cameraAccessButton.centerXAnchor.constraint(equalTo: descriptionLabel.centerXAnchor),
        ])
        cameraAccessButton.layoutIfNeeded()
        CameraPermissionsView.updateButton(button: cameraAccessButton)
    }

    private func setupMicrophoneAccessButton() {
        NSLayoutConstraint.activate([
            microphoneAccessButton.topAnchor.constraint(equalTo: cameraAccessButton.bottomAnchor, constant: 15),
            microphoneAccessButton.centerXAnchor.constraint(equalTo: cameraAccessButton.centerXAnchor),
        ])
        microphoneAccessButton.layoutIfNeeded()
        CameraPermissionsView.updateButton(button: microphoneAccessButton)
    }

    private func setupMediaPickerButton() {
        let guide = UILayoutGuide()
        addLayoutGuide(guide)
        NSLayoutConstraint.activate([
            guide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -1 * (6 + 70 + 6 + 7)),
            guide.heightAnchor.constraint(equalToConstant: 100),
            guide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: -50),
        ])
        NSLayoutConstraint.activate([
            mediaPickerButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            mediaPickerButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            mediaPickerButton.widthAnchor.constraint(equalToConstant: 35),
            mediaPickerButton.heightAnchor.constraint(equalTo: mediaPickerButton.widthAnchor),
        ])
    }

    private static func makeButton(title: String, titleDisabled: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitle(titleDisabled, for: .disabled)
        button.setImage(checkImage, for: .disabled)
        button.setTitleColor(Constants.buttonColor, for: .normal)
        button.setTitleColor(Constants.buttonAcceptedColor, for: .disabled)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = Constants.buttonFont
        button.layer.borderWidth = Constants.borderWidth
        return button
    }

    private static func updateButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height / 2.0
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: button.bounds.height / -4.0, bottom: 0.0, right: 0.0)
        button.contentEdgeInsets = UIEdgeInsets(
            top: button.bounds.height / 5.0,
            left: button.bounds.height / 2.0,
            bottom: button.bounds.height / 5.0,
            right: button.bounds.height / 2.0)
        if button.isEnabled {
            button.backgroundColor = .clear
            button.layer.borderColor = Constants.buttonColor.cgColor
        }
        else {
            button.backgroundColor = Constants.buttonAcceptedBackgroundColor
            button.layer.borderColor = Constants.buttonAcceptedBackgroundColor.cgColor
        }
    }

    @objc private func cameraAccessButtonPressed() {
        delegate?.cameraAccessButtonPressed()
    }

    @objc private func microphoneAccessButtonPressed() {
        delegate?.microphoneAccessButtonPressed()
    }

    func mediaPickerButtonDidPress() {
        delegate?.mediaPickerButtonPressed()
    }

    func resetMediaPickerButton() {
        mediaPickerButton.reset()
    }

}

class CaptureDeviceAuthorizer: CaptureDeviceAuthorizing {

    func requestAccess(for mediaType: AVMediaType, completionHandler: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: mediaType, completionHandler: completionHandler)
    }

    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: mediaType)
    }

}

class CameraPermissionsViewController: UIViewController, CameraPermissionsViewDelegate {

    let captureDeviceAuthorizer: CaptureDeviceAuthorizing

    var delegate: CameraPermissionsViewControllerDelegate?

    private var permissionsView: CameraPermissionsViewable? {
        return view as? CameraPermissionsViewable
    }

    private var ignoreTouchesView: IgnoreTouchesView? {
        return view as? IgnoreTouchesView
    }

    init(captureDeviceAuthorizer: CaptureDeviceAuthorizing) {
        self.captureDeviceAuthorizer = captureDeviceAuthorizer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CameraPermissionsView()
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewFromAccess()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupViewFromAccess()
    }

    func cameraAccessButtonPressed() {
        switch captureDeviceAuthorizer.authorizationStatus(for: .video) {
        case .notDetermined:
            captureDeviceAuthorizer.requestAccess(for: .video) { videoGranted in
                performUIUpdate {
                    self.setupViewFromAccess()
                    self.delegate?.cameraPermissionsChanged(hasFullAccess: self.hasFullAccess())
                }
            }
        case .restricted, .denied:
            openAppSettings()
        case .authorized:
            assertionFailure()
            setupViewFromAccess()
        @unknown default:
            assertionFailure()
        }
    }

    func microphoneAccessButtonPressed() {
        switch captureDeviceAuthorizer.authorizationStatus(for: .audio) {
        case .notDetermined:
            captureDeviceAuthorizer.requestAccess(for: .audio) { audioGranted in
                performUIUpdate {
                    self.setupViewFromAccess()
                    self.delegate?.cameraPermissionsChanged(hasFullAccess: self.hasFullAccess())
                }
            }
        case .restricted, .denied:
            openAppSettings()
        case .authorized:
            assertionFailure()
            setupViewFromAccess()
        @unknown default:
            assertionFailure()
        }
    }

    func mediaPickerButtonPressed() {
        delegate?.didTapMediaPickerButton {
            self.permissionsView?.resetMediaPickerButton()
        }
    }

    func hasFullAccess() -> Bool {
        return hasCameraAccess() && hasMicrophoneAccess()
    }

    private func hasCameraAccess() -> Bool {
        switch captureDeviceAuthorizer.authorizationStatus(for: .video) {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }

    private func hasMicrophoneAccess() -> Bool {
        switch captureDeviceAuthorizer.authorizationStatus(for: .audio) {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }

    private func openAppSettings() {
        delegate?.openAppSettings(completion: nil)
    }

    private func setupViewFromAccess() {
        if hasFullAccess() {
            if ignoreTouchesView == nil {
                view = IgnoreTouchesView()
            }
        }
        else {
            if permissionsView == nil {
                let view = CameraPermissionsView()
                view.delegate = self
                self.view = view
            }
            permissionsView?.updateCameraAccess(hasAccess: hasCameraAccess())
            permissionsView?.updateMicrophoneAccess(hasAccess: hasMicrophoneAccess())
        }
    }

}
