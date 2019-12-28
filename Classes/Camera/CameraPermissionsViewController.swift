//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import SharedUI
import AVFoundation

protocol CameraPermissionsViewDelegate: class {

    func cameraAccessButtonPressed()

    func microphoneAccessButtonPressed()

}

protocol CameraPermissionsViewable: class {

    func updateCameraAccess(hasAccess: Bool)

    func updateMicrophoneAccess(hasAccess: Bool)

}

protocol CameraPermissionsViewControllerDelegate: class {
    func cameraPermissionsChanged(hasFullAccess: Bool)
}

class CameraPermissionsView: UIView, CameraPermissionsViewable {

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

    private var disposables: [NSKeyValueObservation] = []

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
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))

        label.attributedText = attrString
        label.font = Constants.descriptionFont
        label.textColor = Constants.textColor
        label.alpha = Constants.descriptionOpacity
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var cameraAccessButton: UIButton = {
        let button = makeButton(title: "Allow access to camera", titleDisabled: "Camera access granted", action: #selector(cameraAccessButtonPressed)).forAutoLayout()
        return button
    }()

    private lazy var microphoneAccessButton: UIButton = {
        let button = makeButton(title: "Allow access to microphone", titleDisabled: "Microphone access granted", action: #selector(microphoneAccessButtonPressed)).forAutoLayout()
        return button
    }()

    private lazy var checkImage: UIImage = {
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
    }

    func updateMicrophoneAccess(hasAccess: Bool) {
        microphoneAccessButton.isEnabled = !hasAccess
    }

    private func setupView() {
        addSubview(containerView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(cameraAccessButton)
        addSubview(microphoneAccessButton)

        setupContainerView()
        setupTitleView()
        setupDescriptionView()
        setupCameraAccessButton()
        setupMicrophoneAccessButton()
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
    }

    private func setupMicrophoneAccessButton() {
        NSLayoutConstraint.activate([
            microphoneAccessButton.topAnchor.constraint(equalTo: cameraAccessButton.bottomAnchor, constant: 15),
            microphoneAccessButton.centerXAnchor.constraint(equalTo: cameraAccessButton.centerXAnchor),
        ])
    }

    private func makeButton(title: String, titleDisabled: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitle(titleDisabled, for: .disabled)
        button.setImage(checkImage, for: .disabled)
        button.setTitleColor(Constants.buttonColor, for: .normal)
        button.setTitleColor(Constants.buttonAcceptedColor, for: .disabled)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = Constants.buttonFont
        button.layer.borderWidth = Constants.borderWidth
        disposables.append(button.observe(\.bounds) { object, _ in
            object.layer.cornerRadius = object.bounds.height / 2.0
            object.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: object.bounds.height / -4.0, bottom: 0.0, right: 0.0)
            object.contentEdgeInsets = UIEdgeInsets(
                top: object.bounds.height / 5.0,
                left: object.bounds.height / 2.0,
                bottom: object.bounds.height / 5.0,
                right: object.bounds.height / 2.0)
        })
        disposables.append(button.observe(\.isEnabled) { object, _ in
            self.updateButton(button: object)
        })
        updateButton(button: button)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func updateButton(button: UIButton) {
        if button.isEnabled {
            button.backgroundColor = .clear
            button.layer.borderColor = Constants.buttonColor.cgColor
        } else {
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

}

class CameraPermissionsViewController: UIViewController, CameraPermissionsViewDelegate {

    var delegate: CameraPermissionsViewControllerDelegate?

    private var permissionsView: CameraPermissionsViewable? {
        return view as? CameraPermissionsViewable
    }

    private var ignoreTouchesView: IgnoreTouchesView? {
        return view as? IgnoreTouchesView
    }

    override func loadView() {
        let view = CameraPermissionsView()
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        setupViewFromAccess()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupViewFromAccess()
    }

    func cameraAccessButtonPressed() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { videoGranted in
                performUIUpdate {
                    self.setupViewFromAccess()
                    self.delegate?.cameraPermissionsChanged(hasFullAccess: self.hasFullAccess())
                }
            }
        case .restricted:
            openAppSettings()
        case .denied:
            openAppSettings()
        case .authorized:
            assertionFailure()
            setupViewFromAccess()
        }
    }

    func microphoneAccessButtonPressed() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                performUIUpdate {
                    self.setupViewFromAccess()
                    self.delegate?.cameraPermissionsChanged(hasFullAccess: self.hasFullAccess())
                }
            }
        case .restricted:
            openAppSettings()
        case .denied:
            openAppSettings()
        case .authorized:
            assertionFailure()
            setupViewFromAccess()
        }
    }

    func hasFullAccess() -> Bool {
        return hasCameraAccess() && hasMicrophoneAccess()
    }

    private func hasCameraAccess() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            return false
        case .restricted:
            return false
        case .denied:
            return false
        case .authorized:
            return true
        }
    }

    private func hasMicrophoneAccess() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            return false
        case .restricted:
            return false
        case .denied:
            return false
        case .authorized:
            return true
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:]) { success in
                print("Opened settings")
            }
        }
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
