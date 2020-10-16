//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GLKit

protocol PixelBufferView: class {
    var mediaTransform: GLKMatrix4? { get set }
    var isPortrait: Bool { get set }
    func displayPixelBuffer(_ pixelBuffer: CVPixelBuffer)
    func flushPixelBufferCache()
    func reset()
}
