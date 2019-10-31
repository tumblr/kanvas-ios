//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Foundation

class RoundedTexture: Texture {
    
    let minimumStroke: CGFloat
    let maximumStroke: CGFloat
    let textureType: KanvasBrushType = .marker // unused
    
    init(minimumStroke: CGFloat, maximumStroke: CGFloat) {
        self.minimumStroke = minimumStroke
        self.maximumStroke = maximumStroke
    }
    
    func drawPoint(context: CGContext, on point: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        context.addArc(center: point,
                       radius: strokeSize / 2.0,
                       startAngle: 0,
                       endAngle: CGFloat(2.0) * .pi,
                       clockwise: false)
        
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
    
    func drawLine(context: CGContext, from startPoint: CGPoint, to endPoint: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        context.addLines(between: [startPoint, endPoint])
        context.setBlendMode(blendMode)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(strokeSize)
        context.setLineCap(.round)
        context.strokePath()
    }
}
