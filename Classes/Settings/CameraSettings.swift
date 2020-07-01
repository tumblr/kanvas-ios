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
/// - stopMotion: Capturing stop motions, a sequence of images and/or videos
/// - loop: Capturing gifs, a sequence of photos
/// - normal: Capturing single photo or single video
/// - stitch: Capturing stop motions, a sequence of images and/or videos
/// - gif: Capturing gifs, a sequence of photos

@objc public enum CameraMode: Int {
    case stopMotion = 0
    case photo
    case loop
    case normal
    case stitch
    case gif
    
    /// Group
    ///
    /// - video: The mode creates a video from a sequence
    /// - photo: The mode creates a photo
    /// - gif: The mode creates a gif animation
    @objc public enum Group: Int {
        case video = 0
        case photo
        case gif
    }
    
    /// Quantity
    ///
    /// - single: The mode allows just one photo, video or gif
    /// - multiple: The mode creates a sequence of photos and/or videos
    @objc public enum Quantity: Int {
        case single = 0
        case multiple
    }
    
    public var group: Group {
        switch self {
        case .stitch, .normal, .stopMotion:
            return .video
        case .photo:
            return .photo
        case .loop, .gif:
            return .gif
        }
    }
    
    public var quantity: Quantity {
        switch self {
        case .photo, .normal, .gif, .loop:
            return .single
        case .stitch, .stopMotion:
            return .multiple
        }
    }
    
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

    /// The metal camera preview feature. When openGLPreview is true, this will be ignored.
    public var metalPreview: Bool = false

    /// The Camera Filters feature
    /// This enables the UI to select filters in the camera.
    public var cameraFilters: Bool = false

    /// The Experimental Camera Filters feature
    /// This adds experimental filters to the end of the filters picker.
    public var experimentalCameraFilters: Bool = false
    
    /// The Editor feature
    /// This replaces the Preview screen with the Editor.
    public var editor: Bool = false
    
    /// The Editor GIF maker menu
    /// This makes the GIF button open the GIF tools.
    public var editorGIFMaker: Bool = false
    
    /// The Editor Filters feature
    /// This enables the UI to select filters in the editor.
    public var editorFilters: Bool = false
    
    /// The Editor Text feature
    /// This enables the UI to write text in the editor.
    public var editorText: Bool = false
    
    /// The Editor Media feature
    /// This enables the UI to select media in the editor.
    public var editorMedia: Bool = false
    
    /// The Editor Drawing feature
    /// This enables the UI to draw in the editor.
    public var editorDrawing: Bool = false
    
    /// The Media Picker feature
    /// This enables the UI to pick media instead of using the camera.
    public var mediaPicking: Bool = false

    /// The Editor Posting feature
    /// This enables the UI to post media from the editor.
    public var editorPosting: Bool = false

    public var editorPostOptions: Bool = false

    /// The Editor Saving feature
    /// This enables the UI to save media from the editor.
    public var editorSaving: Bool = false
    
    /// The New Camera Modes
    /// This replaces Capture, Photo and Loop modes with Normal, Stitch and GIF modes
    public var newCameraModes = false

    /// GIF support
    /// This enables GIFs to be picked from the media picker, and exported from the Editor.
    public var gifs = false
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

    // MARK: - Stop motion/stitch mode export settings
    public var exportStopMotionPhotoAsVideo: Bool = DefaultCameraSettings.exportStopMotionPhotoAsVideo

    /// MARK: - Camera features
    public var features = DefaultCameraSettings.features

    /// Buttons Swapped on the Camera View
    /// This changes the position between the close icon and the rotate, flash, and ghost icons
    public var topButtonsSwapped = DefaultCameraSettings.topButtonsSwapped
    
    /// Cross Icon In Editor
    /// This changes back carat in the editor to a cross icon
    public var crossIconInEditor = DefaultCameraSettings.crossIconInEditor

    /// Tag button in Editor
    /// This shows a # button in the editor to enable adding tags
    public var showTagButtonInEditor = DefaultCameraSettings.showTagButtonInEditor

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
     Enables/disables loop mode.
     */
    var enableLoopMode: Bool {
        set {
            setMode(.loop, to: newValue)
        }
        get {
            return getMode(.loop)
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
    /**
     Enables/disables normal mode.
     */
    var enableNormalMode: Bool {
        set {
            setMode(.normal, to: newValue)
        }
        get {
            return getMode(.normal)
        }
    }
    /**
     Enables/disables stitch mode.
     */
    var enableStitchMode: Bool {
        set {
            setMode(.stitch, to: newValue)
        }
        get {
            return getMode(.stitch)
        }
    }
    /**
     Enables/disables GIF mode.
     */
    var enableGifMode: Bool {
        set {
            setMode(.gif, to: newValue)
        }
        get {
            return getMode(.gif)
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
            return features.newCameraModes ? .normal : .stopMotion
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

    static let enabledModes: Set<CameraMode> = [.photo, .loop, .stopMotion]
    static let defaultFlashOption: AVCaptureDevice.FlashMode = .off
    static let defaultCameraPositionOption: AVCaptureDevice.Position = .back
    static let defaultImagePreviewOption: ImagePreviewMode = .off
    static let landscapeIsSupported: Bool = false
    static let exportStopMotionPhotoAsVideo: Bool = false
    static let features = CameraFeatures()
    static let topButtonsSwapped: Bool = false
    static let crossIconInEditor: Bool = false
    static let showTagButtonInEditor: Bool = false
}
