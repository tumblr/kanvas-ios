//
//  CameraInputOutput.swift
//  KanvasCamera
//
//  Created by Tony Cheng on 10/31/18.
//

import Foundation

/// An enum for AVCaptureOutput types
enum CameraOutput {
    case photo // AVCapturePhotoOutput
    case video // AVCaptureVideoDataOutput
}

/// Error cases for configuring inputs
enum CameraInputError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}
