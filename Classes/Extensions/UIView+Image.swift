//
//  UIView+Image.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 28/08/2019.
//

import Foundation
import UIKit

extension UIView {
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
