//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import KanvasCamera

final public class KanvasCameraAnalyticsStub: NSObject, KanvasCameraAnalyticsProvider {

    public func logCameraOpen(mode: CameraMode) {
        logString(string: "logCameraOpen mode:\(mode.rawValue)")
    }

    public func logCapturedMedia(type: CameraMode, cameraPosition: AVCaptureDevice.Position, length: TimeInterval, ghostFrameEnabled: Bool, filterType: FilterType) {
        logString(string: "logCapturedMedia type:\(type) cameraPosition:\(cameraPosition) length:\(length) ghostFrameEnabled:\(ghostFrameEnabled) filterType:\(filterType.key() ?? "null")")
    }

    public func logNextTapped() {
        logString(string: "logNextTapped")
    }

    public func logConfirmedMedia(mode: CameraMode, clipsCount: Int, length: TimeInterval) {
        logString(string: "logConfirmedMedia mode:\(mode) clipsCount:\(clipsCount) length:\(length)")
    }

    public func logDismiss() {
        logString(string: "logDismiss")
    }

    public func logPhotoCaptured(cameraPosition: String) {
        logString(string: "logPhotoCaptured cameraPosition:\(cameraPosition)")
    }

    public func logGifCaptured(cameraPosition: String) {
        logString(string: "logGifCaptured cameraPosition:\(cameraPosition)")
    }

    public func logVideoCaptured(cameraPosition: String) {
        logString(string: "logVideoCaptured cameraPosition:\(cameraPosition)")
    }

    public func logFlipCamera() {
        logString(string: "logFlipCamera")
    }

    public func logDeleteSegment() {
        logString(string: "logDeleteSegment")
    }

    public func logFlashToggled() {
        logString(string: "logFlashToggled")
    }
    
    public func logImagePreviewToggled(enabled: Bool) {
        logString(string: "logImagePreviewToggled enabled:\(enabled)")
    }
    
    public func logUndoTapped() {
        logString(string: "logUndoTapped")
    }
    
    public func logPreviewDismissed() {
        logString(string: "logPreviewDismissed")
    }

    public func logMovedClip() {
        logString(string: "logMovedClip")
    }
    
    public func logPinchedZoom() {
        logString(string: "logPinchedZoom")
    }
    
    public func logSwipedZoom() {
        logString(string: "logSwipedZoom")
    }

    public func logOpenFiltersSelector() {
        logString(string: "logOpenFiltersSelector")
    }

    public func logFilterSelected(filterType: FilterType) {
        logString(string: "logFilterSelected filterType:\(filterType.key() ?? "null")")
    }
    
    func logString(string: String) {
        NSLog("\(self): \(string)")
    }

}
