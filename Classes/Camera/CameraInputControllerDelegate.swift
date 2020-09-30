//
//  CameraInputControllerDelegate.swift
//  KanvasCamera
//
//  Created by Tony Cheng on 10/31/18.
//

import Foundation

/// Delegate for handling camera input actions
protocol CameraInputControllerDelegate: class {
    /// Delegate to reset the current device zoom
    func cameraInputControllerShouldResetZoom()
    
    /// Delegate method to set zoom based on pinch
    ///
    /// - Parameters:
    ///   - gesture: the pinch gesture
    func cameraInputControllerPinched(gesture: UIPinchGestureRecognizer)

    func cameraInputControllerHasFullAccess() -> Bool
}
