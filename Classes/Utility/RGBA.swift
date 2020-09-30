//
//  RGBA.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 05/02/2019.
//

import Foundation
import UIKit

class RGBA {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    
    init(color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
