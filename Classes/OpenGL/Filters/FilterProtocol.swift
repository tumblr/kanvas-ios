//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

protocol FilterProtocol {
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer)
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?) -> CVPixelBuffer?
    func cleanup()
    
    var outputFormatDescription: CMFormatDescription? { get set }
}
