//
//  CGPoint+Operators.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 04/09/2019.
//

import Foundation
import UIKit

/// Extension for adding and substracting two CGPoint values
extension CGPoint {
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}
