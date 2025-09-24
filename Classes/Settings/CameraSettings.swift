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

@objc public enum CameraMode: Int, OptionSelectorItem {
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
    
    var description: String {
        return KanvasStrings.name(for: self)
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
    
    /// This enables metal backed filteres
    public var metalFilters: Bool = false

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
    
    /// The Editor Crop Rotate feature
    /// This enables the UI to crop & rotate your image in the editor.
    public var editorCropRotate: Bool = false

    /// The Media Picker feature
    /// This enables the UI to pick media instead of using the camera.
    public var mediaPicking: Bool = false

    /// The Editor Posting feature
    /// This enables the UI to post media from the editor.
    public var editorPosting: Bool = false

    public var editorPostOptions: Bool = false

    /// Editor Confirm Button
    /// Moves the editor confirm button to the top right
    public var editorConfirmAtTop: Bool = false

    /// The Editor Saving feature
    /// This enables the UI to save media from the editor.
    public var editorSaving: Bool = false
    
    /// The New Camera Modes
    /// This replaces Capture, Photo and Loop modes with Normal, Stitch and GIF modes
    public var newCameraModes = false

    /// GIF support
    /// This enables GIFs to be picked from the media picker, and exported from the Editor.
    public var gifs = false
    
    /// Mode selector tooltip
    /// This enables a tooltip to appear below the mode selector when the camera launches for the first time.
    public var modeSelectorTooltip: Bool = false
    
    /// Shutter button tooltip
    /// This enables a tooltip to appear above the shutter button when the camera launches for the first time.
    public var shutterButtonTooltip: Bool = false

    /// Button to Mute Sound
    /// This adds an option to mute sounds from videos during editing and in export.
    public var muteButton = false


    /// Multi-Export support
    /// This enables multiple images/videos to be taken, edited, and then exported
    public var multipleExports = false

    /// Scale media to fill
    /// This scales the imported media to fill the screen by setting the `mediaContentMode` to `scaleAspectFill` on the pixel buffer views.
    /// The buffer views will resize their contents during drawing to fill the screen.
    public var scaleMediaToFill: Bool = false

    /// Resizes Text View Fonts
    /// Whether or not to resize the text view fonts progressively to fit withinthe editing area.
    public var resizesFonts: Bool = true
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

    /// Cog icon in Editor
    /// This sets a cog icon for the posting options button in the editor
    public var showCogIconInEditor = DefaultCameraSettings.showCogIconInEditor
    
    /// Tag button in Editor
    /// This shows a # button in the editor to enable adding tags
    public var showTagButtonInEditor = DefaultCameraSettings.showTagButtonInEditor
    
    /// Tag collection in Editor
    /// This shows a collection of tags in the editor
    public var showTagCollectionInEditor = DefaultCameraSettings.showTagCollectionInEditor
    
    /// Quick post button in Editor
    /// This shows a post button that makes quick options appear when long pressed
    public var showQuickPostButtonInEditor = DefaultCameraSettings.showQuickPostButtonInEditor
    
    /// Blog Switcher in Editor
    /// This shows a blog switcher that makes quick options appear when long pressed
    public var showBlogSwitcherInEditor = DefaultCameraSettings.showBlogSwitcherInEditor
    
    /// Auto-open GIF Maker in Editor
    public func editorShouldStartGIFMaker(mode: CameraMode?) -> Bool {
        if mode?.group == .gif {
            return gifCameraShouldStartGIFMaker
        }
        return _editorShouldStartGIFMaker
    }

    public func setEditorShouldStartGIFMaker(_ newValue: Bool) {
        _editorShouldStartGIFMaker = newValue
    }

    private var _editorShouldStartGIFMaker: Bool = DefaultCameraSettings.editorShouldStartGIFMaker

    /// Auto-open GIF Maker after GIF Camera
    public var gifCameraShouldStartGIFMaker: Bool = DefaultCameraSettings.editorShouldStartGIFMaker

    /// Animate the movement of control in the editor
    public var animateEditorControls: Bool = DefaultCameraSettings.animateEditorControls

    /// Whether to show a shadow to the sides of the media clips
    public var showShadowOverMediaClips: Bool = DefaultCameraSettings.showShadowOverMediaClips

    /// The Font Selector button uses the currently selected font for its label
    public var fontSelectorUsesFont: Bool = DefaultCameraSettings.fontFamilyUsesFont

    /// The aspect ratio to pin the Editor View to
    public var aspectRatio: CGFloat? = nil

    override public init() { }

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
    static let showCogIconInEditor: Bool = false
    static let showTagButtonInEditor: Bool = false
    static let showTagCollectionInEditor: Bool = false
    static let showQuickPostButtonInEditor: Bool = false
    static let showBlogSwitcherInEditor: Bool = false
    static let editorShouldStartGIFMaker: Bool = false
    static let gifCameraShouldStartGIFMaker: Bool = false
    static let fontFamilyUsesFont: Bool = false
    static let animateEditorControls: Bool = true
    static let showShadowOverMediaClips: Bool = true
}
