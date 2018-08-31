//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

fileprivate struct TopOptionsConstants {
    static let CameraFlipAnimationsDuration: TimeInterval = 0.15
    static func CameraFlipAnimationsTransform(baseTransform: CATransform3D) -> CATransform3D {
        return CATransform3DRotate(baseTransform, .pi/2, 0, 0, 1)
    }
}

/// The possible states of options for the camera
///
/// - flashOn: represents the camera flash or torch enabled
/// - flashOff: represents the camera flash or torch disabled
/// - frontCamera: represents the device's front (selfie) camera
/// - backCamera: presents the device's back camera
enum TopOption {
    case flashOn
    case flashOff
    case frontCamera
    case backCamera
}

// MARK: - Setting to Top Option conversion
fileprivate protocol TopOptionConvertible {
    var topOption: TopOption { get }
}

extension AVCaptureDevice.FlashMode: TopOptionConvertible {
    var topOption: TopOption {
        switch self {
        case .off: return .flashOff
        case .on: return .flashOn
        case .auto: return .flashOff
        }
    }
}

extension AVCaptureDevice.Position: TopOptionConvertible {
    var topOption: TopOption {
        switch self {
        case .back: return .backCamera
        case .front: return .frontCamera
        case .unspecified: return .backCamera
        }
    }
}


// MARK: - Top options creation
extension CameraController {
    
    func getOptions(from settings: CameraSettings) -> [Option<TopOption>] {
        let (animation, completion) = getAnimationForCameraFlip()
        return [
            Option(option: settings.defaultFlashOption.topOption,
                   image: getImage(for: settings.defaultFlashOption),
                   type: .twoOptionsImages(alternateOption: settings.notDefaultFlashOption.topOption,
                                           alternateImage: getImage(for: settings.notDefaultFlashOption))),
            Option(option: settings.defaultCameraPositionOption.topOption,
                   image: KanvasCameraImages.CameraPositionImage,
                   type: .twoOptionsAnimation(animation: animation,
                                              duration: TopOptionsConstants.CameraFlipAnimationsDuration,
                                              completion: completion))
            
        ]
    }
    
    func getImage(for option: AVCaptureDevice.FlashMode) -> UIImage? {
        if option == .on {
            return KanvasCameraImages.FlashOnImage
        } else {
            return KanvasCameraImages.FlashOffImage
        }
    }
    
    func getAnimationForCameraFlip() -> ((UIView) -> (), (UIView) -> ()) {
        let animation = { (view: UIView) in
            view.layer.transform = TopOptionsConstants.CameraFlipAnimationsTransform(baseTransform: view.layer.transform)
        }
        let completed = { (view: UIView) in
            UIView.animate(withDuration: TopOptionsConstants.CameraFlipAnimationsDuration, animations: {
                animation(view)
            }, completion: { _ in view.layer.transform = CATransform3DIdentity })   // We clear all transformation to leave it normal again.
        }
        return (animation, completed)
    }
    
}
