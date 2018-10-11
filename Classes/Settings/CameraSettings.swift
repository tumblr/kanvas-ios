//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

/// Camera Modes available
///
/// - photo: Capturing photos
/// - gif: Capturing gifs, a sequence of photos
/// - stopMotion: Capturing stop motions, a sequence of images and/or videos
@objc public enum CameraMode: Int {
    case stopMotion = 0
    case photo
    case gif
    
    private var order: Int {
        return self.rawValue
    }
    
}

// A class that defines the settings for the Kanvas Camera
@objc public final class CameraSettings: NSObject {

    // MARK: - Modes
    /**
     Enables/disables modes.
     - note: Defaults to stop motion and gif.
     - note: The set can't be empty.
     */
    public var enabledModes: Set<CameraMode> {
        set {
            guard !newValue.isEmpty else {
                assertionFailure("New value for camera modes is empty")
                return
            }
            _enabledModes = newValue
        }
        get {
            return _enabledModes
        }
    }
    
    private var _enabledModes: Set<CameraMode> = DefaultCameraSettings.EnabledModes
    
    /**
     Camera mode which starts active.
     - note: Defaults to .none, which will activate the first active
     mode in the list.
     - note: You can't set as default mode one which is not enabled, it will be ignored.
     */
    public var defaultMode: CameraMode? {
        set {
            if let mode = newValue, enabledModes.contains(mode) {
                _defaultMode = mode
            }
            if newValue == nil {
                _defaultMode = newValue
            }
        }
        get {
            return _defaultMode
        }
    }
    
    private var _defaultMode: CameraMode?
    
    // MARK: - Camera Position settings
    
    /// Camera position option which starts active.
    /// - note: Defaults to back.
    /// - note: Can't be unspecified.
    public var defaultCameraPositionOption: AVCaptureDevice.Position {
        set {
            if newValue != .unspecified {
                _defaultCameraPositionOption = newValue
            }
        }
        get {
            return _defaultCameraPositionOption
        }
    }
    
    private var _defaultCameraPositionOption: AVCaptureDevice.Position = DefaultCameraSettings.DefaultCameraPositionOption
    
    // MARK: - Flash settings
    
    /// Flash option which starts active.
    /// - note: Defaults to flash off.
    public var preferredFlashOption: AVCaptureDevice.FlashMode = DefaultCameraSettings.DefaultFlashOption
    
    // MARK: - Landscape support
    public var cameraSupportsLandscape: Bool = DefaultCameraSettings.LandscapeIsSupported
    
    // MARK: - Stop motion mode export settings
    public var exportStopMotionPhotoAsVideo: Bool = DefaultCameraSettings.ExportStopMotionPhotoAsVideo
    
    override public init() { }
    
}


// MARK: - External utilities
public extension CameraSettings {
    /**
     Enables/disables photo mode.
     */
    public var enablePhotoMode: Bool {
        set {
            setMode(.photo, to: newValue)
        }
        get {
            return getMode(.photo)
        }
    }
    /**
     Enables/disables gif mode.
     */
    public var enableGifMode: Bool {
        set {
            setMode(.gif, to: newValue)
        }
        get {
            return getMode(.gif)
        }
    }
    /**
     Enables/disables stop motion mode.
     */
    public var enableStopMotionMode: Bool {
        set {
            setMode(.stopMotion, to: newValue)
        }
        get {
            return getMode(.stopMotion)
        }
    }
    
    private func setMode(_ mode: CameraMode, to on: Bool) {
        if on {
            enabledModes.insert(mode)
        }
        else {
            enabledModes.remove(mode)
        }
    }
    
    private func getMode(_ mode: CameraMode) -> Bool {
        return enabledModes.contains(mode)
    }
    
}

// MARK: - Internal utilities
extension CameraSettings {
    
    var orderedEnabledModes: [CameraMode] {
        return Array(enabledModes).sorted { $0.rawValue < $1.rawValue }
    }
    
    var initialMode: CameraMode {
        // enabledModes will always have at least one value as its precondition.
        guard let firstMode = orderedEnabledModes.first else {
            assertionFailure("should have at least one enabled mode")
            return CameraMode.stopMotion
        }
        return defaultMode ?? firstMode
    }
    
    var notDefaultFlashOption: AVCaptureDevice.FlashMode {
        if preferredFlashOption == .on {
            return .off
        }
        else {
            return .on
        }
    }
    
    var notDefaultCameraPositionOption: AVCaptureDevice.Position {
        if defaultCameraPositionOption == .front {
            return .back
        }
        else {
            return .front
        }
    }
    
}

// MARK: - Default settings
private struct DefaultCameraSettings {
    
    static let EnabledModes: Set<CameraMode> = [.photo, .gif, .stopMotion]
    static let DefaultFlashOption: AVCaptureDevice.FlashMode = .off
    static let DefaultCameraPositionOption: AVCaptureDevice.Position = .back
    static let LandscapeIsSupported: Bool = false
    static let ExportStopMotionPhotoAsVideo: Bool = true
    
}
