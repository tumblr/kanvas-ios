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

/// Camera Features
///
/// Struct which represents all camera features which are the same value for the duration of a camera session.
public struct CameraFeatures {

    /// The Ghost Frame feature
    public var ghostFrame: Bool = false

    /// The OpenGL Camera Preview feature
    public var openGLPreview: Bool = false

    /// The OpenGL Camera Capture feature
    public var openGLCapture: Bool = false

    /// The Camera Filters feature
    /// This enables the UI to select filters in the camera.
    public var cameraFilters: Bool = false

    /// The Experimental Camera Filters feature
    /// This adds experimental filters to the end of the filters picker.
    public var experimentalCameraFilters: Bool = false
    
    /// The Editor feature
    /// This replaces the Preview screen with the Editor.
    public var editor: Bool = false
    
    /// The Editor Filters feature
    /// This enables the UI to select filters in the editor.
    public var editorFilters: Bool = false
    
    /// The Editor Media feature
    /// This enables the UI to select media in the editor.
    public var editorMedia: Bool = false
    
    /// The Editor Drawing feature
    /// This enables the UI to draw in the editor.
    public var editorDrawing: Bool = false

    /// The Media Picker feature
    /// This enables the UI to pick media instead of using the camera.
    public var mediaPicking: Bool = false
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

    private var _enabledModes: Set<CameraMode> = DefaultCameraSettings.enabledModes

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

    private var _defaultCameraPositionOption: AVCaptureDevice.Position = DefaultCameraSettings.defaultCameraPositionOption

    // MARK: - Flash settings

    /// Flash option which starts active.
    /// - note: Defaults to flash off.
    public var preferredFlashOption: AVCaptureDevice.FlashMode = DefaultCameraSettings.defaultFlashOption

    /// Fullscreen image preview which starts disabled.
    /// - note: Defaults to image preview off.
    public var imagePreviewOption: ImagePreviewMode = DefaultCameraSettings.defaultImagePreviewOption

    // MARK: - Landscape support
    public var cameraSupportsLandscape: Bool = DefaultCameraSettings.landscapeIsSupported

    // MARK: - Stop motion mode export settings
    public var exportStopMotionPhotoAsVideo: Bool = DefaultCameraSettings.exportStopMotionPhotoAsVideo

    /// MARK: - Camera features
    public var features = DefaultCameraSettings.features

    override public init() { }

}


// MARK: - External utilities
public extension CameraSettings {
    /**
     Enables/disables photo mode.
     */
    var enablePhotoMode: Bool {
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
    var enableGifMode: Bool {
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
    var enableStopMotionMode: Bool {
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

    /// Returns the opposite of the value that has been set for the fullscreen image preview
    var notDefaultImagePreviewOption: ImagePreviewMode {
        if imagePreviewOption == .on {
            return .off
        }
        else {
            return .on
        }
    }

}

// MARK: - Default settings
private struct DefaultCameraSettings {

    static let enabledModes: Set<CameraMode> = [.photo, .gif, .stopMotion]
    static let defaultFlashOption: AVCaptureDevice.FlashMode = .off
    static let defaultCameraPositionOption: AVCaptureDevice.Position = .back
    static let defaultImagePreviewOption: ImagePreviewMode = .off
    static let landscapeIsSupported: Bool = false
    static let exportStopMotionPhotoAsVideo: Bool = false
    static let features = CameraFeatures()

}
