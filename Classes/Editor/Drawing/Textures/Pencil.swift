//
//  Pencil.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 27/06/2019.
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
