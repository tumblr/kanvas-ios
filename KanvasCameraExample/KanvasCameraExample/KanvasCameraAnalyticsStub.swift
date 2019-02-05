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
        logString(string: "\(#function) mode:\(mode.rawValue)")
    }

    public func logCapturedMedia(type: CameraMode, cameraPosition: AVCaptureDevice.Position, length: TimeInterval, ghostFrameEnabled: Bool) {
        logString(string: "\(#function) type:\(type) cameraPosition:\(cameraPosition) length:\(length) ghostFrameEnabled:\(ghostFrameEnabled)")
    }

    public func logNextTapped() {
        logString(string: "\(#function)")
    }

    public func logConfirmedMedia(mode: CameraMode, clipsCount: Int, length: TimeInterval) {
        logString(string: "\(#function) mode:\(mode) clipsCount:\(clipsCount) length:\(length)")
    }

    public func logDismiss() {
        logString(string: "\(#function)")
    }

    public func logPhotoCaptured(cameraPosition: String) {
        logString(string: "\(#function) cameraPosition:\(cameraPosition)")
    }

    public func logGifCaptured(cameraPosition: String) {
        logString(string: "\(#function) cameraPosition:\(cameraPosition)")
    }

    public func logVideoCaptured(cameraPosition: String) {
        logString(string: "\(#function) cameraPosition:\(cameraPosition)")
    }

    public func logFlipCamera() {
        logString(string: "\(#function)")
    }

    public func logDeleteSegment() {
        logString(string: "\(#function)")
    }

    public func logFlashToggled() {
        logString(string: "\(#function)")
    }
    
    public func logImagePreviewToggled(enabled: Bool) {
        logString(string: "\(#function) enabled:\(enabled)")
    }
    
    public func logUndoTapped() {
        logString(string: "\(#function)")
    }

    public func logPreviewDismissed() {
        logString(string: "\(#function)")
    }

    public func logMovedClip() {
        logString(string: "\(#function)")
    }
    
    public func logPinchedZoom() {
        logString(string: "\(#function)")
    }
    
    public func logSwipedZoom() {
        logString(string: "\(#function)")
    }
    
    func logString(string: String) {
        NSLog("\(self): \(string)")
    }
}
