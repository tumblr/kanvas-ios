//
//  CameraPermissionsViewController.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 12/26/19.
//

import Foundation
import UIKit
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

    let showMediaPicker: Bool

    private struct Constants {
        static let borderWidth: CGFloat = 2
        static let titleFont: UIFont = KanvasCameraFonts.shared.permissions.titleFont
        static let textColor: UIColor = .white
        static let descriptionFont: UIFont = KanvasCameraFonts.shared.permissions.descriptionFont
        static let descriptionOpacity: CGFloat = 0.65
        static let buttonFont: UIFont = KanvasCameraFonts.shared.permissions.buttonFont
        static let buttonColor: UIColor = .init(red: 0, green: 184.0/255.0, blue: 1.0, alpha: 1.0)
        static let buttonAcceptedBackgroundColor: UIColor = .init(hex: 0x00cf35)
        static let buttonAcceptedColor: UIColor = .black
        static let buttonBorderWidth: CGFloat = 1.5
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Post to Tumblr", comment: "Title of camera permissions screen")
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let description = NSLocalizedString("Allow access so you can start taking photos and videos", comment: "Message on camera permissions screen to explain why the Tumblr app needs camera and microphone permissions")
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineSpacing = Constants.descriptionFont.pointSize * 0.5
        let descriptionAttributedString = NSMutableAttributedString(string: description)
        descriptionAttributedString.addAttribute(.paragraphStyle, value: descriptionParagraphStyle, range: NSMakeRange(0, descriptionAttributedString.length))

        label.attributedText = descriptionAttributedString
        label.font = Constants.descriptionFont
        label.textColor = Constants.textColor
        label.alpha = Constants.descriptionOpacity
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var cameraAccessButton: UIButton = {
        let title = NSLocalizedString("Allow access to camera", comment: "Button on camera permissions screen to initiate the sytem prompt for camera access")
        let titleDisabled = NSLocalizedString("Camera access granted", comment: "Label on camera permissions screen to indicate camera access is granted")
        let button = CameraPermissionsView.makeButton(title: title, titleDisabled: titleDisabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cameraAccessButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var microphoneAccessButton: UIButton = {
        let title = NSLocalizedString("Allow access to microphone", comment: "Button on camera permissions screen to initiate the sytem prompt for microphone access")
        let titleDisabled = NSLocalizedString("Microphone access granted", comment: "Label on camera permissions screen to indicate microphone access is granted")
        let button = CameraPermissionsView.makeButton(title: title, titleDisabled: titleDisabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(microphoneAccessButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var mediaPickerButton: MediaPickerButtonView = {
        let settings = CameraSettings()
        settings.features.mediaPicking = showMediaPicker
        let button = MediaPickerButtonView(settings: settings)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        return button
    }()

    private static var checkImage: UIImage? = {
        return KanvasCameraImages.permissionCheckmark?.withRenderingMode(.alwaysTemplate)
    }()

    weak var delegate: CameraPermissionsViewDelegate?

    init(showMediaPicker: Bool, frame: CGRect = .zero) {
        self.showMediaPicker = showMediaPicker

        super.init(frame: frame)

        setupView()
    }

    override init(frame: CGRect) {
        self.showMediaPicker = false

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
        let bottomMargin: CGFloat = deviceDependentBottomMargin()
        NSLayoutConstraint.activate([
            guide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
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
    
    
    private func deviceDependentBottomMargin() -> CGFloat {
        guard Device.belongsToIPhoneXGroup == true else {
            return CGFloat(floatLiteral: 96.0)
        }
        
        return CGFloat(floatLiteral: 90.0)
    }

    private static func makeButton(title: String, titleDisabled: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitle(titleDisabled, for: .disabled)
        button.setImage(checkImage, for: .disabled)
        button.tintColor = Constants.buttonAcceptedColor
        button.setTitleColor(Constants.buttonColor, for: .normal)
        button.setTitleColor(Constants.buttonAcceptedColor, for: .disabled)
        button.contentHorizontalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.font = Constants.buttonFont
        button.layer.borderWidth = Constants.borderWidth
        return button
    }

    private static func updateButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height / 2.0
        let verticalInset: CGFloat = 4.5
        button.imageEdgeInsets = UIEdgeInsets(top: verticalInset, left: button.bounds.height / -4.0, bottom: verticalInset, right: 0.0)
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

    let shouldShowMediaPicker: Bool

    weak var delegate: CameraPermissionsViewControllerDelegate?

    private var permissionsView: CameraPermissionsViewable? {
        return view as? CameraPermissionsViewable
    }

    private var ignoreTouchesView: IgnoreTouchesView? {
        return view as? IgnoreTouchesView
    }

    init(shouldShowMediaPicker: Bool, captureDeviceAuthorizer: CaptureDeviceAuthorizing) {
        self.captureDeviceAuthorizer = captureDeviceAuthorizer
        self.shouldShowMediaPicker = shouldShowMediaPicker
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CameraPermissionsView(showMediaPicker: shouldShowMediaPicker, frame: .zero)
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
                    self.setupViewFromAccessAndNotifyPermissionsChanged()
                }
            }
        case .restricted, .denied:
            openAppSettings()
        case .authorized:
            assertionFailure("How was this button pressed if we're already authorized!?")
            self.setupViewFromAccessAndNotifyPermissionsChanged()
        @unknown default:
            assertionFailure()
        }
    }

    func microphoneAccessButtonPressed() {
        switch captureDeviceAuthorizer.authorizationStatus(for: .audio) {
        case .notDetermined:
            captureDeviceAuthorizer.requestAccess(for: .audio) { audioGranted in
                performUIUpdate {
                    self.setupViewFromAccessAndNotifyPermissionsChanged()
                }
            }
        case .restricted, .denied:
            openAppSettings()
        case .authorized:
            assertionFailure("How was this button pressed if we're already authorized!?")
            self.setupViewFromAccessAndNotifyPermissionsChanged()
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

    private func setupViewFromAccessAndNotifyPermissionsChanged() {
        setupViewFromAccess()
        delegate?.cameraPermissionsChanged(hasFullAccess: self.hasFullAccess())
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
