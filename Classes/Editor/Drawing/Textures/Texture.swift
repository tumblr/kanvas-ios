//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Foundation

protocol Texture {
    var minimumStroke: CGFloat { get }
    var maximumStroke: CGFloat { get }
    var textureType: KanvasBrushType { get }
    
    func drawPoint(context: CGContext, on point: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor)
    func drawLine(context: CGContext, points: [CGPoint], size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor)
}
