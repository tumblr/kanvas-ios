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
    
    func drawLine(context: CGContext, points: [CGPoint], size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        guard points.count == 3, let firstPoint = points.object(at: 0), let secondPoint = points.object(at: 1), let thirdPoint = points.object(at: 2) else {
            assertionFailure("Need three points to draw curve")
            return
        }
        let firstMidPoint = firstPoint.midPoint(to: secondPoint)
        let secondMidPoint = secondPoint.midPoint(to: thirdPoint)
        context.move(to: firstMidPoint)
        context.addQuadCurve(to: secondMidPoint, control: secondPoint)
        context.setBlendMode(blendMode)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(strokeSize)
        context.setLineCap(.round)
        context.strokePath()
    }
}

fileprivate extension CGPoint {
    func midPoint(to point: CGPoint) -> CGPoint {
        return CGPoint(x: (self.x + point.x) * 0.5, y: (self.y + point.y) * 0.5)
    }
}
