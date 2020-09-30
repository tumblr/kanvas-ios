//
//  Texture.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 27/06/2019.
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
