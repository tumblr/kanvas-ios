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
    var switchInputDimensions: Bool { get set }
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval)
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, scaleToFillSize: CGSize?)
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval, scaleToFillSize: CGSize?) -> CVPixelBuffer?
    func refreshFilter()
    func reset()
}
