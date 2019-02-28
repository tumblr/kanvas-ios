//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

/// Protocol for filters
protocol FilterProtocol {

    /// Uses the sampleBuffer's dimensions to initialize framebuffers and pixel buffers.
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer)

    /// Uses the provided pixelBuffer to render the filter to a new pixel buffer, and returns the new pixel buffer.
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?) -> CVPixelBuffer?

    /// Cleans up all resources allocated by the filter.
    func cleanup()

    /// Output format set by setupFormatDescription
    var outputFormatDescription: CMFormatDescription? { get set }
}
