//
//  TextDimensions.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 02/09/2019.
//

import Foundation
import UIKit

final class ViewTransformations {
    
    static let defaultPosition: CGPoint = .zero
    static let defaultScale: CGFloat = 1.0
    static let defaultRotation: CGFloat = 0.0
    
    var position: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    
    init(position: CGPoint = ViewTransformations.defaultPosition,
         scale: CGFloat = ViewTransformations.defaultScale,
         rotation: CGFloat = ViewTransformations.defaultRotation) {
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
    }
}
