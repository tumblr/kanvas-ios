//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for photo handlers
protocol PhotoOutputHandlerProtocol {

    /// Function to take a photo
    ///
    /// - Parameters:
    ///   - settings: the AVCapturePhotoSettings for the AVCapturePhotoOutput instance
    ///   - completion: returns the photo as a UIImage if successful
    func takePhoto(settings: AVCapturePhotoSettings, completion: @escaping (UIImage?) -> Void)
}

/// A handler for taking photos
final class PhotoOutputHandler: NSObject, PhotoOutputHandlerProtocol {

    private let photoOutput: AVCapturePhotoOutput?
    private var completionBlock: ((UIImage?) -> Void)?

    /// The designated initializer for the PhotoOutpuHandler
    ///
    /// - Parameter photoOutput: The AVCapturePhotoOutput that will capture photos. Optional for error handling
    required init(photoOutput: AVCapturePhotoOutput?) {
        self.photoOutput = photoOutput
    }

    /// Takes a photo given the current settings and returns as a UIImage
    ///
    /// - Parameters:
    ///   - settings: settings such as flash. Usually will be the default AVCapturePhotoSettings()
    ///   - completion: returns a UIImage if successful, otherwise nil
    func takePhoto(settings: AVCapturePhotoSettings, completion: @escaping (UIImage?) -> Void) {
        if let output = photoOutput {
            completionBlock = completion
            output.capturePhoto(with: settings, delegate: self)
        }
        else {
            completion(nil)
        }
    }
}

extension PhotoOutputHandler: AVCapturePhotoCaptureDelegate {
    // iOS 11 method for handling photo capture
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            completionBlock = nil
        }
        guard let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data) else {
                completionBlock?(nil)
                return
        }
        completionBlock?(image)
    }
}
