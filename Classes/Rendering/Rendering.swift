//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreMedia
import GLKit

/// Callbacks for rendering
protocol RenderingDelegate: class {
    /// Called when renderer has a processed pixel buffer ready for display. This may skip frames, so it's only
    /// intended to be used for display purposes.
    ///
    /// - Parameters:
    ///   - pixelBuffer: the filtered pixel buffer
    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer)

    /// Called when renderer has a processed pixel buffer ready. This is called for every frame, so this can be
    /// used for recording purposes.
    ///
    /// - Parameters:
    ///   - pixelBuffer: the filtered pixel buffer
    ///   - presentationTime: The append time
    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime)

    /// Called when no buffers are available
    func rendererRanOutOfBuffers()
}

protocol Rendering: class {
    var delegate: RenderingDelegate? { get set }
    var filterType: FilterType { get set }
    var imageOverlays: [CGImage] { get set }
    var mediaTransform: GLKMatrix4? { get set }
    var outputDimensions: CGSize { get set }
    var switchInputDimensions: Bool { get set }
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval)
    func output(filteredPixelBuffer: CVPixelBuffer)
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval) -> CVPixelBuffer?
    func refreshFilter()
    func reset()
}
