//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Foundation

final class Marker: Texture {
    
    static let angle: Float = 3.0 * Float.pi / 4.0
    static let alpha: CGFloat = 0.5
    let minimumStroke: CGFloat = 18
    let maximumStroke: CGFloat = 40
    
    func drawPoint(context: CGContext, on point: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        let startPoint = CGPoint(x: point.x - 2, y: point.y)
        let endPoint = CGPoint(x: point.x + 2, y: point.y)
        drawLine(context: context, from: startPoint, to: endPoint, size: strokeSize, blendMode: blendMode, color: color)
    }
    
    func drawLine(context: CGContext, from startPoint: CGPoint, to endPoint: CGPoint, size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        let height = strokeSize / 2
        
        let horizontalOffset = CGFloat(cos(Marker.angle)) * height / 2.0
        let verticalOffset = CGFloat(sin(Marker.angle)) * height / 2.0
        
        let points: [CGPoint] = [
            CGPoint(x: startPoint.x + horizontalOffset, y: startPoint.y - verticalOffset),
            CGPoint(x: startPoint.x - horizontalOffset, y: startPoint.y + verticalOffset),
            CGPoint(x: endPoint.x - horizontalOffset, y: endPoint.y + verticalOffset),
            CGPoint(x: endPoint.x + horizontalOffset, y: endPoint.y - verticalOffset)
        ]
        
        context.setAlpha(Marker.alpha)
        context.addLines(between: points)
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
