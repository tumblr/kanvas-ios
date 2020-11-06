//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

private struct CameraOptionsConstants {
    static let cameraFlipAnimationsDuration: TimeInterval = 0.15
    static func cameraFlipAnimationsTransform(baseTransform: CATransform3D) -> CATransform3D {
        return CATransform3DRotate(baseTransform, .pi/2, 0, 0, 1)
    }
}

/// The possible states of options for the camera
///
/// - flashOn: represents the camera flash or torch enabled
/// - flashOff: represents the camera flash or torch disabled
/// - frontCamera: represents the device's front (selfie) camera
/// - backCamera: represents the device's back camera
/// - imagePreviewOn: represents the fullscreen preview enabled
/// - imagePreviewOff: represents the fullscreen preview disabled
enum CameraOption {
    case flashOn
    case flashOff
    case frontCamera
    case backCamera
    case imagePreviewOn
    case imagePreviewOff
}

// MARK: - Setting to CameraOption conversion
private protocol CameraOptionConvertible {
    var cameraOption: CameraOption { get }
}

extension AVCaptureDevice.FlashMode: CameraOptionConvertible {
    var cameraOption: CameraOption {
        switch self {
        case .off: return .flashOff
        case .on: return .flashOn
        case .auto: return .flashOff
        @unknown default:
            return .flashOff
        }
    }
}

extension AVCaptureDevice.Position: CameraOptionConvertible {
    var cameraOption: CameraOption {
        switch self {
        case .back: return .backCamera
        case .front: return .frontCamera
        case .unspecified: return .backCamera
        @unknown default:
            return .backCamera
        }
    }
}

public enum ImagePreviewMode: CameraOptionConvertible {
    case on
    case off
    
    var cameraOption: CameraOption {
        switch self {
        case .on: return .imagePreviewOn
        case .off: return .imagePreviewOff
        }
    }
}

// MARK: - Top options creation
extension CameraController {
    
    /// function for returning default CameraOptions based on settings
    ///
    /// - Parameter settings: The input CameraSettings
    /// - Returns: an array of Options wrapping CameraOption enums
    func getOptions(from settings: CameraSettings) -> [[Option<CameraOption>]] {
        let (animation, completion) = getAnimationForCameraFlip()
        var options = [
            [
                Option(option: settings.defaultCameraPositionOption.cameraOption,
                       image: settings.cameraToolsRedesign ? KanvasCameraImages.cameraRotateImage : KanvasCameraImages.cameraPositionImage,
                       type: .twoOptionsAnimation(animation: animation,
                                                  duration: CameraOptionsConstants.cameraFlipAnimationsDuration,
                                                  completion: completion))
            ],
            [
                Option(option: settings.preferredFlashOption.cameraOption,
                       image: getImage(for: settings.preferredFlashOption, with: settings),
                       type: .twoOptionsImages(alternateOption: settings.notDefaultFlashOption.cameraOption,
                                               alternateImage: getImage(for: settings.notDefaultFlashOption, with: settings))),
            ],
        ]
        if settings.features.ghostFrame {
            options.append([
                Option(option: settings.imagePreviewOption.cameraOption,
                       image: getImage(for: settings.imagePreviewOption, with: settings),
                       type: .twoOptionsImages(alternateOption: settings.notDefaultImagePreviewOption.cameraOption,
                                               alternateImage: getImage(for: settings.notDefaultImagePreviewOption, with: settings)))
            ])
        }
        return options
    }
    
    /// function to get the image for a camera flash mode
    ///
    /// - Parameter option: AVCaptureDevice.FlashMode, on or off / auto
    /// - Returns: an optional image
    func getImage(for option: AVCaptureDevice.FlashMode, with settings: CameraSettings) -> UIImage? {
        if settings.cameraToolsRedesign {
            if option == .on {
                return KanvasCameraImages.cameraFlashOnImage
            }
            else {
                return KanvasCameraImages.cameraFlashOffImage
            }
        }
        else {
            if option == .on {
                return KanvasCameraImages.flashOnImage
            }
            else {
                return KanvasCameraImages.flashOffImage
            }
        }
    }
    
    /// function to get the image for the image preview button
    ///
    /// - Parameter option: ImagePreviewMode, on or off
    /// - Returns: an optional image
    func getImage(for option: ImagePreviewMode, with settings: CameraSettings) -> UIImage? {
        if settings.cameraToolsRedesign {
            if option == .on {
                return KanvasCameraImages.ghostFrameOnImage
            }
            else {
                return KanvasCameraImages.ghostFrameOffImage
            }
        }
        else {
            if option == .on {
                return KanvasCameraImages.imagePreviewOnImage
            }
            else {
                return KanvasCameraImages.imagePreviewOffImage
            }
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
