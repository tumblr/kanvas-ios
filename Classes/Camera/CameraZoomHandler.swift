//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Default values for the input camera
private struct CameraZoomConstants {
    static let minimumZoom: CGFloat = 1.0
    static let zoomDistanceDivisor: CGFloat = 50
}

/// protocol for handling the current zoom on a device
protocol CameraZoomHandlerDelegate: AnyObject {
    /// Gets the current device for zooming
    var currentDeviceForZooming: AVCaptureDevice? { get }
}

/// A class to handle the pinch and pan zoom gestures and apply them to a given device
final class CameraZoomHandler {
    
    /// The delegate for the camera zoom
    weak var delegate: CameraZoomHandlerDelegate?
    private var initialZoomFactor: CGFloat = CameraZoomConstants.minimumZoom
    /// These two variables act as a reference point for the pan zoom
    private var baseZoom: CGFloat = CameraZoomConstants.minimumZoom
    private var startingPoint: CGPoint?
    private var currentDevice: AVCaptureDevice? {
        return delegate?.currentDeviceForZooming
    }
    private let analyticsProvider: KanvasAnalyticsProvider?
    
    /// The designated initializer
    ///
    /// - Parameter analyticsProvider: Optionally provide an analytics class
    init(analyticsProvider: KanvasAnalyticsProvider? = nil) {
        self.analyticsProvider = analyticsProvider
    }
    
    /// Sets the video camera zoom factor
    ///
    /// - Parameter
    ///   - gesture: the pinch gesture recognizer that performs the zoom action.
    func setZoom(gesture: UIPinchGestureRecognizer) {
        guard let camera = currentDevice else { return }
        let zoomFactor = gesture.scale * initialZoomFactor
        let validZoomFactor = minMaxZoom(captureDevice: camera, zoomFactor: zoomFactor)
        startingPoint = nil
        
        switch gesture.state {
        case .began:
            analyticsProvider?.logPinchedZoom()
            fallthrough
        case .changed:
            updateZoom(captureDevice: camera, zoomFactor: validZoomFactor)
        case .ended, .failed, .cancelled:
            initialZoomFactor = validZoomFactor
            updateZoom(captureDevice: camera, zoomFactor: validZoomFactor)
        default:
            break
        }
    }
    
    /// Sets the video camera zoom factor
    ///
    /// - Parameter
    ///   - zoomFactor: should be a value between 1 and the videoMaxZoomFactor. The standard zoom is 1.
    ///   - gesture: the long press gesture recognizer that performs the zoom action.
    func setZoom(point: CGPoint, gesture: UILongPressGestureRecognizer) {
        guard let camera = currentDevice else { return }
        switch gesture.state {
        case .began:
            analyticsProvider?.logSwipedZoom()
            preparePan(point: point, zoom: initialZoomFactor)
        case .changed:
            if startingPoint == nil {
                preparePan(point: point, zoom: initialZoomFactor)
            }
            let zoom = calculateZoom(captureDevice: camera, currentPoint: point)
            updateZoom(captureDevice: camera, zoomFactor: zoom)
            initialZoomFactor = zoom
        case .ended, .failed, .cancelled:
            let zoom = calculateZoom(captureDevice: camera, currentPoint: point)
            updateZoom(captureDevice: camera, zoomFactor: zoom)
            initialZoomFactor = zoom
            preparePan(point: nil, zoom: zoom)
        default:
            break
        }
    }
    
    /// Prepares pan zoom to be used
    ///
    /// - Parameter
    ///   - point: location of the screen that will act as a reference to zoom in or out
    ///   - zoom: base zoom that will act as a reference to zoom in or out
    private func preparePan(point: CGPoint?, zoom: CGFloat) {
        startingPoint = point
        baseZoom = zoom
    }
    
    /// Sets the video camera zoom factor
    ///
    /// - Parameter
    ///   - captureDevice: a device that provides video
    ///   - currentPoint: location of the finger on the screen
    private func calculateZoom(captureDevice: AVCaptureDevice, currentPoint: CGPoint) -> CGFloat {
        guard let initialPoint = startingPoint else { return initialZoomFactor }
        let yDistance = initialPoint.y - currentPoint.y
        return minMaxZoom(captureDevice: captureDevice, zoomFactor: yDistance / CameraZoomConstants.zoomDistanceDivisor + baseZoom)
    }
    
    /// Returns zoom value between the minimum and maximum zoom values
    ///
    /// - Parameters:
    ///   - captureDevice: a device that provides video
    ///   - zoomFactor: zoom value to be set
    func updateZoom(captureDevice: AVCaptureDevice, zoomFactor: CGFloat) {
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = zoomFactor
        } catch {
            // The zoom factor is different for various devices, setting the zoom shouldn't crash
            NSLog("failed to zoom for \(zoomFactor)")
        }
        captureDevice.unlockForConfiguration()
    }
    
    /// Returns zoom value between the minimum and maximum zoom values
    ///
    /// - Parameters:
    ///   - captureDevice: a device that provides video
    ///   - zoomFactor: zoom value to be checked
    func minMaxZoom(captureDevice: AVCaptureDevice, zoomFactor: CGFloat) -> CGFloat {
        return (CameraZoomConstants.minimumZoom ... captureDevice.activeFormat.videoMaxZoomFactor).clamp(zoomFactor)
    }
    
    /// The current camera's zoom
    ///
    /// - Returns: returns the current device's videoZoomFactor, if a device is found
    func currentZoom() -> CGFloat? {
        return currentDevice?.videoZoomFactor
    }
    
    /// Resets the zoom to the minimum value
    func resetZoom() {
        guard let camera = currentDevice else { return }
        initialZoomFactor = CameraZoomConstants.minimumZoom
        updateZoom(captureDevice: camera, zoomFactor: CameraZoomConstants.minimumZoom)
    }
    
}
