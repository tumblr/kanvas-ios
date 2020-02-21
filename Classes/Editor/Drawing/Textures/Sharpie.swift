//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Foundation

class Sharpie: Texture {
    
    let roundedTexture: RoundedTexture
    let minimumStroke: CGFloat = 7
    let maximumStroke: CGFloat = 18
    let textureType: KanvasBrushType = .sharpie
    
    init() {
        self.roundedTexture = RoundedTexture(minimumStroke: minimumStroke, maximumStroke: maximumStroke)
    }
    
    func drawPoint(context: CGContext, on point: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        roundedTexture.drawPoint(context: context, on: point, size: strokeSize, blendMode: blendMode, color: color)
    }
    
    func drawLine(context: CGContext, points: [CGPoint], size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        roundedTexture.drawLine(context: context, points: points, size: strokeSize, blendMode: blendMode, color: color)
    }
}
