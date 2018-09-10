//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

private struct CameraOptionsConstants {
    static let cameraFlipAnimationsDuration: TimeInterval = 0.15
    static func cameraFlipAnimationsTransform(baseTransform: CATransform3D) -> CATransform3D {
        return CATransform3DRotate(baseTransform, .pi/2, 0, 0, 1)
    }
}

/// The possible states of options for the camera that are related to devices
///
/// - flashOn: represents the camera flash or torch enabled
/// - flashOff: represents the camera flash or torch disabled
/// - frontCamera: represents the device's front (selfie) camera
/// - backCamera: presents the device's back camera
enum CameraDeviceOption {
    case flashOn
    case flashOff
    case frontCamera
    case backCamera
}

// MARK: - Setting to CameraDeviceOption conversion
fileprivate protocol CameraOptionConvertible {
    var cameraDeviceOption: CameraDeviceOption { get }
}

extension AVCaptureDevice.FlashMode: CameraOptionConvertible {
    var cameraDeviceOption: CameraDeviceOption {
        switch self {
        case .off: return .flashOff
        case .on: return .flashOn
        case .auto: return .flashOff
        }
    }
}

extension AVCaptureDevice.Position: CameraOptionConvertible {
    var cameraDeviceOption: CameraDeviceOption {
        switch self {
        case .back: return .backCamera
        case .front: return .frontCamera
        case .unspecified: return .backCamera
        }
    }
}


// MARK: - Top options creation
extension CameraController {
    
    /// function for returning default CameraDeviceOptions based on settings
    ///
    /// - Parameter settings: The input CameraSettings
    /// - Returns: an array of Options wrapping CameraDeviceOption enums
    func getOptions(from settings: CameraSettings) -> [Option<CameraDeviceOption>] {
        let (animation, completion) = getAnimationForCameraFlip()
        return [
            Option(option: settings.preferredFlashOption.cameraDeviceOption,
                   image: getImage(for: settings.preferredFlashOption),
                   type: .twoOptionsImages(alternateOption: settings.notDefaultFlashOption.cameraDeviceOption,
                                           alternateImage: getImage(for: settings.notDefaultFlashOption))),
            Option(option: settings.defaultCameraPositionOption.cameraDeviceOption,
                   image: KanvasCameraImages.CameraPositionImage,
                   type: .twoOptionsAnimation(animation: animation,
                                              duration: CameraOptionsConstants.cameraFlipAnimationsDuration,
                                              completion: completion))
            
        ]
    }
    
    /// function to get the image for a camera flash mode
    ///
    /// - Parameter option: AVCaptureDevice.FlashMode, on or off / auto
    /// - Returns: an optional image
    func getImage(for option: AVCaptureDevice.FlashMode) -> UIImage? {
        if option == .on {
            return KanvasCameraImages.FlashOnImage
        }
        else {
            return KanvasCameraImages.FlashOffImage
        }
    }
    
    /// function that returns the default animation for rotating the camera button
    func getAnimationForCameraFlip() -> ((UIView) -> (), (UIView) -> ()) {
        let animation = { (view: UIView) in
            view.layer.transform = CameraOptionsConstants.cameraFlipAnimationsTransform(baseTransform: view.layer.transform)
        }
        let completed = { (view: UIView) in
            UIView.animate(withDuration: CameraOptionsConstants.cameraFlipAnimationsDuration, animations: {
                animation(view)
            }, completion: { _ in view.layer.transform = CATransform3DIdentity })   // We clear all transformation to leave it normal again.
        }
        return (animation, completed)
    }
    
}
