//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Foundation

final class Pencil: Texture {
    
    private let roundedTexture: RoundedTexture
    let minimumStroke: CGFloat = 1
    let maximumStroke: CGFloat = 4
    let textureType: KanvasBrushType = .pencil
    
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
