//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreMedia
import GLKit

protocol Rendering: class {
    var delegate: RendererDelegate? { get set }
    var filterType: FilterType { get set }
    var imageOverlays: [CGImage] { get set }
    var mediaTransform: GLKMatrix4? { get set }
    var outputDimensions: CGSize { get set }
    var switchInputDimensions: Bool { get set }
    var backgroundFillColor: CGColor { get set }
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval)
    func output(filteredPixelBuffer: CVPixelBuffer)
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval) -> CVPixelBuffer?
    func refreshFilter()
    func reset()
}
