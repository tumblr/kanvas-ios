//
//  CALayer+CGImage.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 8/1/19.
//

import Foundation
import CoreGraphics
import UIKit

/// Extension that converts CALayer into a CGImage
extension CALayer {

    func cgImage() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image?.cgImage
    }

}
