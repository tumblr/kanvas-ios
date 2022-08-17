//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import AVFoundation

protocol CaptureDeviceAuthorizing: AnyObject {

    func requestAccess(for mediaType: AVMediaType, completionHandler: @escaping (Bool) -> ())

    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus

}

protocol CameraPermissionsViewDelegate: AnyObject {

    func requestCameraAccess()
    
    func requestMicrophoneAccess()
    
    func openAppSettings()
}

protocol CameraPermissionsViewControllerDelegate: AnyObject {

    func cameraPermissionsChanged(hasFullAccess: Bool)

    func openAppSettings(completion: ((Bool) -> ())?)
}

class CameraPermissionsView: UIView {

    private struct Constants {
        static let borderWidth: CGFloat = 2
        static let titleFont: UIFont = KanvasFonts.shared.permissions.titleFont
        static let textColor: UIColor = .white
        static let descriptionFont: UIFont = KanvasFonts.shared.permissions.descriptionFont
        static let descriptionOpacity: CGFloat = 0.65
        static let buttonFont: UIFont = KanvasFonts.shared.permissions.buttonFont
        static let buttonColor: UIColor = KanvasColors.shared.permissionsButtonColor
        static let buttonAcceptedColor: UIColor = .black
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, settingsButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = KanvasStrings.shared.cameraPermissionsTitleLabel
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = KanvasStrings.shared.cameraPermissionsDescriptionLabel
        label.font = Constants.descriptionFont
        label.textColor = Constants.textColor
        label.alpha = Constants.descriptionOpacity
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var settingsButton: UIButton = {
        let title = NSLocalizedString("PhotoAccessNoAccessAction", comment: "PhotoAccessNoAccessAction")
        let titleDisabled = NSLocalizedString("PhotoAccessNoAccessAction", comment: "PhotoAccessNoAccessAction")
        let button = CameraPermissionsView.makeButton(title: title, titleDisabled: titleDisabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openAppSettings), for: .touchUpInside)
        return button
    }()

    private static var checkImage: UIImage? = {
        return KanvasImages.permissionCheckmark?.withRenderingMode(.alwaysTemplate)
    }()

    weak var delegate: CameraPermissionsViewDelegate?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(containerView)
        addSubview(contentStack)

        setupContainerView()
        setupContentStack()
        setupSettingsButton()
    }

    private func setupContainerView() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupContentStack() {
        NSLayoutConstraint.activate([
            contentStack.heightAnchor.constraint(equalToConstant: 250),
            contentStack.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor),
            contentStack.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            readableContentGuide.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
        ])
    }

    private func setupSettingsButton() {
        settingsButton.layer.cornerRadius = settingsButton.bounds.height / 2.0
        settingsButton.backgroundColor = .clear
        settingsButton.layer.borderColor = Constants.buttonColor.cgColor
        settingsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
    
    @objc private func openAppSettings() {
        delegate?.openAppSettings()
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
    
    var isViewBlockingCameraAccess: Bool { !isIgnoringTouches }
    
    weak var delegate: CameraPermissionsViewControllerDelegate?

    var permissionsView: CameraPermissionsView? {
        return view as? CameraPermissionsView
    }
    
    private var isIgnoringTouches: Bool {
        return view is IgnoreTouchesView
    }


    init(captureDeviceAuthorizer: CaptureDeviceAuthorizing, delegate: CameraPermissionsViewControllerDelegate) {
        self.captureDeviceAuthorizer = captureDeviceAuthorizer
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CameraPermissionsView(frame: .zero)
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
        if hasFullAccess() { return }
        
        requestCameraAccess()
        requestMicrophoneAccess()
    }
    
    func requestCameraAccess() {
        switch captureDeviceAuthorizer.authorizationStatus(for: .video) {
        case .notDetermined:
            captureDeviceAuthorizer.requestAccess(for: .video) { videoGranted in
                performUIUpdate {
                    self.setupViewFromAccessAndNotifyPermissionsChanged()
                }
            }
        case .restricted, .denied, .authorized:
            return
        @unknown default:
            return
        }
    }

    func requestMicrophoneAccess() {
        switch captureDeviceAuthorizer.authorizationStatus(for: .audio) {
        case .notDetermined:
            captureDeviceAuthorizer.requestAccess(for: .audio) { audioGranted in
                performUIUpdate {
                    self.setupViewFromAccessAndNotifyPermissionsChanged()
                }
            }
        case .restricted, .denied, .authorized:
            return
        @unknown default:
            return
        }
    }
    
    func openAppSettings() {
        delegate?.openAppSettings(completion: nil)
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

    private func setupViewFromAccessAndNotifyPermissionsChanged() {
        setupViewFromAccess()
        delegate?.cameraPermissionsChanged(hasFullAccess: self.hasFullAccess())
    }

    private func setupViewFromAccess() {
        if hasFullAccess() {
            showIgnoreTouchesView()
        }
        else {
            showPermissionsView()
        }
    }
    
    private func showPermissionsView() {
        if permissionsView == nil {
            let view = CameraPermissionsView()
            view.delegate = self
            self.view = view
        }
    }
    
    private func showIgnoreTouchesView() {
        if !isIgnoringTouches {
            view = IgnoreTouchesView()
        }
    }

}
