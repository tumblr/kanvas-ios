//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Foundation

final class Marker: Texture {
    
    static let distanceCoefficient: CGFloat = 0.1
    static let strokeAngle: Float = 3.0 * Float.pi / 4.0
    static let alpha: CGFloat = 0.6
    let minimumStroke: CGFloat = 18
    let maximumStroke: CGFloat = 40
    let textureType: KanvasBrushType = .marker
    
    func drawPoint(context: CGContext, on point: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        let startPoint = CGPoint(x: point.x - 2, y: point.y)
        let endPoint = CGPoint(x: point.x + 2, y: point.y)
        drawLine(context: context, from: startPoint, to: endPoint, size: strokeSize, blendMode: blendMode, color: color)
    }
    
    func drawLine(context: CGContext, from startPoint: CGPoint, to endPoint: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        let height = strokeSize / 2
        
        let angleXOffset = CGFloat(cos(Marker.strokeAngle)) * height / 2.0
        let angleYOffset = CGFloat(sin(Marker.strokeAngle)) * height / 2.0
        
        let distanceX = endPoint.x - startPoint.x
        let distanceY = endPoint.y - startPoint.y
        var directionAngle = atan(-distanceY/distanceX)
        
        if (distanceY < 0 && distanceX < 0) || (distanceY > 0 && distanceX < 0) {
            directionAngle = directionAngle + .pi
        }
        
        let distanceXOffset = Marker.distanceCoefficient * cos(directionAngle)
        let distanceYOffset = Marker.distanceCoefficient * sin(directionAngle)
        
        let points: [CGPoint] = [
            CGPoint(x: startPoint.x + angleXOffset, y: startPoint.y - angleYOffset),
            CGPoint(x: startPoint.x - angleXOffset, y: startPoint.y + angleYOffset),
            CGPoint(x: endPoint.x - angleXOffset + distanceXOffset, y: endPoint.y + angleYOffset - distanceYOffset),
            CGPoint(x: endPoint.x + angleXOffset + distanceXOffset, y: endPoint.y - angleYOffset - distanceYOffset)
        ]
        
        context.setAlpha(Marker.alpha)
        context.addLines(between: points)
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
