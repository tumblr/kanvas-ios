//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import UIKit

/// A handler for taking photos
final class PhotoOutputHandler: NSObject {

    private let photoOutput: AVCapturePhotoOutput?
    private var completionBlock: ((UIImage?) -> Void)?

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
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        defer {
            completionBlock = nil
        }
        guard let buffer = photoSampleBuffer,
              let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
              let image = UIImage(data: data) else {
            completionBlock?(nil)
            return
        }
        completionBlock?(image)
    }
}
