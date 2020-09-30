//
//  Marker.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 27/06/2019.
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
        let height = strokeSize / 2
        let startPoint = CGPoint(x: point.x - height, y: point.y)
        let endPoint = CGPoint(x: point.x + height, y: point.y)
        drawLine(context: context, points: [startPoint, point, endPoint], size: strokeSize, blendMode: blendMode, color: color)
    }
    
    func drawLine(context: CGContext, points: [CGPoint], size strokeSize: CGFloat, blendMode: CGBlendMode, color: UIColor) {
        guard points.count == 3, let firstPoint = points.object(at: 0), let secondPoint = points.object(at: 1), let thirdPoint = points.object(at: 2) else {
            assertionFailure("Need three points to draw curve")
            return
        }
        let startPoint = firstPoint.midPoint(to: secondPoint)
        let endPoint = secondPoint.midPoint(to: thirdPoint)

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
        
        let startPointTop = CGPoint(x: startPoint.x + angleXOffset, y: startPoint.y - angleYOffset)
        let startPointBottom = CGPoint(x: startPoint.x - angleXOffset, y: startPoint.y + angleYOffset)
        let controlPointBottom = CGPoint(x: secondPoint.x - angleXOffset, y: secondPoint.y + angleYOffset)
        let endPointBottom = CGPoint(x: endPoint.x - angleXOffset + distanceXOffset, y: endPoint.y + angleYOffset - distanceYOffset)
        let endPointTop = CGPoint(x: endPoint.x + angleXOffset + distanceXOffset, y: endPoint.y - angleYOffset - distanceYOffset)
        let controlPointTop = CGPoint(x: secondPoint.x + angleXOffset + distanceXOffset, y: secondPoint.y - angleYOffset - distanceYOffset)

        context.setAlpha(Marker.alpha)
        context.move(to: startPointTop)
        context.addLine(to: startPointBottom)
        context.addQuadCurve(to: endPointBottom, control: controlPointBottom)
        context.addLine(to: endPointTop)
        context.addQuadCurve(to: startPointTop, control: controlPointTop)
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

fileprivate extension CGPoint {
    func midPoint(to point: CGPoint) -> CGPoint {
        return CGPoint(x: (self.x + point.x) * 0.5, y: (self.y + point.y) * 0.5)
    }
}
