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
    
    init(minimumStroke: CGFloat, maximumStroke: CGFloat) {
        self.minimumStroke = minimumStroke
        self.maximumStroke = maximumStroke
    }
    
    func drawPoint(context: CGContext, on point: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        let height = strokeSize / 2
        
        context.addArc(center: point,
                       radius: height / 2.0,
                       startAngle: 0,
                       endAngle: CGFloat(2.0) * .pi,
                       clockwise: false)
        
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
    
    func drawLine(context: CGContext, from startPoint: CGPoint, to endPoint: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        let height = strokeSize / 2
        
        let adjacentCathetus = endPoint.x - startPoint.x
        let oppositeCathetus = startPoint.y - endPoint.y
        let angle = atan(oppositeCathetus / adjacentCathetus)
        
        let horizontalOffset = CGFloat(sin(angle)) * height / 2.0
        let verticalOffset = CGFloat(cos(angle)) * height / 2.0
        
        let points: [CGPoint] = [
            CGPoint(x: startPoint.x - horizontalOffset, y: startPoint.y - verticalOffset),
            CGPoint(x: startPoint.x + horizontalOffset, y: startPoint.y + verticalOffset),
            CGPoint(x: endPoint.x + horizontalOffset, y: endPoint.y + verticalOffset),
            CGPoint(x: endPoint.x - horizontalOffset, y: endPoint.y - verticalOffset)
        ]
        
        context.addLines(between: points)
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fillPath()
        
        for limitPoint in [startPoint, endPoint] {
            context.addArc(center: limitPoint,
                           radius: height / 2.0,
                           startAngle: 0,
                           endAngle: CGFloat(2.0) * .pi,
                           clockwise: false)
            
            context.fillPath()
        }
    }
}
