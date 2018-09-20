//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

/// A protocol for injecting analytics into the KanvasCamera module
@objc public protocol KanvasCameraAnalyticsProvider {

    /// Logs an event when the camera is opened
    ///
    /// - Parameter position: what photo mode was opened
    func logCameraOpen(mode: CameraMode)

    /// Logs an event when the camera is dismissed without exporting media
    func logDismiss()

    /// Logs an event when media is captured
    ///
    /// - Parameters:
    ///   - type: the camera mode used to capture media.
    ///   - cameraPosition: the back or front camera
    ///   - length: the duration of the video created, in seconds
    func logCapturedMedia(type: CameraMode, cameraPosition: AVCaptureDevice.Position, length: TimeInterval)
    
    /// Logs an event when the flip camera button is tapped
    func logFlipCamera()

    /// Logs an event when a segment is deleted
    func logDeleteSegment()

    /// Logs an event when the flash button is tapped
    func logFlashToggled()

    /// Logs an event when the undo button is tapped
    func logUndoTapped()

    /// Logs an event when the preview (next) button is tapped
    func logNextTapped()

    /// Logs an event if the preview screen is closed without exporting media
    func logPreviewDismissed()
    
    /// Logs an event when the confirm button is tapped
    ///
    /// - Parameters:
    ///   - mode: the mode used to create the media
    ///   - clipsCount: the number of clips used, if a video
    ///   - length: the duration of the video created, in seconds
    func logConfirmedMedia(mode: CameraMode, clipsCount: Int, length: TimeInterval)
}
