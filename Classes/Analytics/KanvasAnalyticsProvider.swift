//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

public enum KanvasBrushType: Int {
    case pencil, marker, sharpie

    public func string() -> String {
        switch self {
        case .pencil:
            return "pencil"
        case .marker:
            return "marker"
        case .sharpie:
            return "sharpie"
        }
    }
}

public enum KanvasColorSelectionTool: Int {
    case swatch, gradient, eyedropper

    public func string() -> String {
        switch self {
        case .swatch:
            return "swatch"
        case .gradient:
            return "gradient"
        case .eyedropper:
            return "eyedropper"
        }
    }
}

public enum KanvasDrawingAction: Int {
    case tap, fill, stroke

    public func string() -> String {
        switch self {
        case .tap:
            return "tap"
        case .fill:
            return "fill"
        case .stroke:
            return "stroke"
        }
    }
}

public enum KanvasTextAlignment: Int {
    case left, center, right

    public func string() -> String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        }
    }

    public static func from(alignment: NSTextAlignment?) -> KanvasTextAlignment? {
        guard let alignment = alignment else { return nil }
        switch alignment {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        default:
            return nil
        }
    }
}

public enum KanvasDashboardOpenAction: Int {
    case tap, swipe

    public func string() -> String {
        switch self {
        case .tap:
            return "tap"
        case .swipe:
            return "swipe"
        }
    }
}

public enum KanvasDashboardDismissAction: Int {
    case tap, swipe

    public func string() -> String {
        switch self {
        case .tap:
            return "tap"
        case .swipe:
            return "swipe"
        }
    }
}

public enum KanvasMediaType: Int {
    case image, video, frames, livePhoto

    public func string() -> String {
        switch self {
        case .image:
            return "image"
        case .video:
            return "video"
        case .frames:
            return "frames"
        case .livePhoto:
            return "live-photo"
        }
    }
}

public enum KanvasGIFPlaybackMode: Int {
    case loop, rebound, reverse

    init(from playbackOption: PlaybackOption) {
        switch playbackOption {
        case .loop:
            self = .loop
        case .rebound:
            self = .rebound
        case .reverse:
            self = .reverse
        }
    }

    public func string() -> String {
        switch self {
        case .loop:
            return "loop"
        case .rebound:
            return "rebound"
        case .reverse:
            return "reverse"
        }
    }
}

/// A protocol for injecting analytics into the Kanvas module
public protocol KanvasAnalyticsProvider {

    /// Logs an event when the camera is opened
    ///
    /// - Parameter mode: what photo mode was opened
    func logCameraOpen(mode: CameraMode)

    /// Logs an event when the camera is dismissed without exporting media
    func logDismiss()

    /// Logs an event when media is captured
    ///
    /// - Parameters:
    ///   - type: the camera mode used to capture media.
    ///   - cameraPosition: the back or front camera
    ///   - length: the duration of the video created, in seconds
    ///   - ghostFrameEnabled: whether the ghost frame feature is enabled or not
    ///   - filterType: what filter was applied when capturing media. nil when feature is disabled
    func logCapturedMedia(type: CameraMode, cameraPosition: AVCaptureDevice.Position, length: TimeInterval, ghostFrameEnabled: Bool, filterType: FilterType)
    
    /// Logs an event when the flip camera button is tapped
    func logFlipCamera()

    /// Logs an event when a segment is deleted
    func logDeleteSegment()

    /// Logs an event when the flash button is tapped
    func logFlashToggled()

    /// Logs an event when the image preview button is tapped
    func logImagePreviewToggled(enabled: Bool)
    
    /// Logs an event when the undo button is tapped
    func logUndoTapped()

    /// Logs an event when the preview button is tapped
    func logNextTapped()

    /// Logs an event if the preview screen is closed without exporting media
    func logPreviewDismissed()
    
    /// Logs an event when a media clip is moved
    func logMovedClip()
    
    /// Logs an event when the user pinches to zoom
    func logPinchedZoom()
    
    /// Logs an event when the user swipes up while recording to zoom
    func logSwipedZoom()

    /// Logs an event when the confirm button is tapped
    ///
    /// - Parameters:
    ///   - mode: the mode used to create the media
    ///   - clipsCount: the number of clips used, if a video
    ///   - length: the duration of the video created, in seconds
    func logConfirmedMedia(mode: CameraMode, clipsCount: Int, length: TimeInterval)

    /// Logs an event when the filters selector is opened
    func logOpenFiltersSelector()

    /// Logs an event when a filter is selected
    /// - Parameter filterType: The selected filter
    func logFilterSelected(filterType: FilterType)

    func logMediaPickerOpen()

    func logMediaPickerDismiss()

    func logMediaPickerPickedMedia(ofTypes mediaTypes: [KanvasMediaType])

    func logEditorOpen()

    func logEditorBack()

    /// Logs an event when the filters button is tapped in the editor
    func logEditorFiltersOpen()

    /// Logs an event when a filter is selected in the editor
    func logEditorFilterSelected(filterType: FilterType)

    /// Logs an event when the drawing button is tapped in the editor
    func logEditorDrawingOpen()

    /// Logs an event when the crop & rotate button is tapped in the editor
    func logEditorCropRotateOpen()
    
    /// Logs an event when the stroke size is changed
    /// - Parameter strokeSize: the size of the stroke, between 0 and 1
    func logEditorDrawingChangeStrokeSize(strokeSize: Float)

    /// Logs an event when the brush is changed
    /// - Parameter brushType: the brush that was selected
    func logEditorDrawingChangeBrush(brushType: KanvasBrushType)

    /// Logs an event when someone selects a color
    /// - Parameter selectionTool: the color selection tool used
    func logEditorDrawingChangeColor(selectionTool: KanvasColorSelectionTool)

    /// Logs an event when someone draws
    /// - Parameter brushType: the brush that was selected
    /// - Parameter strokeSize: the size of the stroke, between 0 and 1
    /// - Parameter drawType: the type of drawing action performed
    func logEditorDrawStroke(brushType: KanvasBrushType, strokeSize: Float, drawType: KanvasDrawingAction)

    /// Logs an event when someone undoes a drawing or erasing action
    func logEditorDrawingUndo()

    /// Logs an event when someone uses the eraser
    /// - Parameter brushType: the brush that was selected
    /// - Parameter strokeSize: the size of the stroke, between 0 and 1
    /// - Parameter drawType: the type of erasing action performed
    func logEditorDrawingEraser(brushType: KanvasBrushType, strokeSize: Float, drawType: KanvasDrawingAction)

    /// Logs an event when someone confirms drawing
    func logEditorDrawingConfirm()

    /// Logs an event when tapping the text tool to add a new text overlay
    func logEditorTextAdd()

    /// Logs an event when tapping on an existing text overlay to edit it
    func logEditorTextEdit()

    /// Logs an event when a text overlay is confirmed
    /// - Parameter isNew: whether this text overlay is newly added or not
    /// - Parameter font: the font
    /// - Parameter alignment: the text alignment
    /// - Parameter highlighted: whether the text is highlighted or not
    func logEditorTextConfirm(isNew: Bool, font: UIFont, alignment: KanvasTextAlignment, highlighted: Bool)

    /// Logs an event when a text overlay is moved
    func logEditorTextMove()

    /// Logs an event when a text overlay is removed
    func logEditorTextRemove()

    /// Logs an event when the font is changed
    /// - Parameter font: the font
    func logEditorTextChange(font: UIFont)

    /// Logs an event when the text alignment is changed
    /// - Parameter alignment: the text alignment
    func logEditorTextChange(alignment: KanvasTextAlignment)

    /// Logs an event when the text highlight is changed
    /// - Parameter highlighted: whether the text is highlighted
    func logEditorTextChange(highlighted: Bool)

    /// Logs an event when the text color changes
    /// - Parameter color: Always true
    func logEditorTextChange(color: Bool)

    /// Logs an event when media is created from the editor
    func logEditorCreatedMedia(clipsCount: Int, length: TimeInterval)

    /// Logs an event when Kanvas is opened from the Dashboard
    /// - Parameter openAction: the way Kanvas was opened - either a swipe or a tap
    func logOpenFromDashboard(openAction: KanvasDashboardOpenAction)

    /// Logs an event when Kanvas is dismissed from the Dashboard
    /// - Parameter dismissAction: the way Kanvas was dismissed - either a swipe or a tap
    func logDismissFromDashboard(dismissAction: KanvasDashboardDismissAction)

    /// Logs when someone posts from Kanvas
    func logPostFromDashboard()

    /// Logs when someone changes the blog to post to
    func logChangeBlogForPostFromDashboard()

    /// Logs when someone only saves media from Kanvas
    func logSaveFromDashboard()

    /// Logs when someone opens compose from Kanvas
    func logOpenComposeFromDashboard()

    /// Logs when someone taps the tag button in the Editor
    func logEditorTagTapped()

    /// Logs when the Create icon is presented in the Dashboard header
    func logIconPresentedOnDashboard()
    
    /// Logs when the Media Drawer is opened
    func logEditorMediaDrawerOpen()
    
    /// Logs when the Media Drawer is closed
    func logEditorMediaDrawerClosed()
    
    /// Logs when the stickers tab is selected in the Media Drawer
    func logEditorMediaDrawerSelectStickers()
    
    /// Logs when a sticker pack is selected in the Media Drawer
    /// - Parameter stickerPackId: the ID of the sticker pack that was selected
    func logEditorStickerPackSelect(stickerPackId: String)
    
    /// Logs when a sticker is added in the canvas
    /// - Parameter stickerId: the ID of the sticker that was added
    func logEditorStickerAdd(stickerId: String)
    
    /// Logs when a sticker is removed from the canvas
    /// - Parameter stickerId: the ID of the sticker that was removed
    func logEditorStickerRemove(stickerId: String)
    
    /// Logs when a sticker is moved through the canvas
    /// - Parameter stickerId: the ID of the sticker that was moved
    func logEditorStickerMove(stickerId: String)

    func logEditorGIFButtonToggle(_ value: Bool)
    func logEditorGIFOpen()
    func logEditorGIFOpenTrim()
    func logEditorGIFOpenSpeed()
    func logEditorGIFRevert()
    func logEditorGIFConfirm(duration: TimeInterval, playbackMode: KanvasGIFPlaybackMode, speed: Float)
    func logEditorGIFChange(playbackMode: KanvasGIFPlaybackMode)
    func logEditorGIFChange(speed: Float)
    func logEditorGIFChange(trimStart: TimeInterval, trimEnd: TimeInterval)

    /// Logs when the "next" button that opens APO is pressed in the Editor
    /// - Parameter page: page presenting the post options
    func logAdvancedOptionsOpen(page: String)

    /// Logs when the given screen has become visible.
    /// - Parameter screen: The screen that became visible.
    func logScreenView(_ screen: KanvasScreen)

    /// Logs when the given screen is not longer visible.
    /// - Parameter screen: The screen not longer visible.
    func logScreenLeave(_ screen: KanvasScreen)
}
