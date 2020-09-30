//
//  UIImage+color.swift
//  KanvasCameraExample
//
//  Created by Jimmy Schementi on 3/8/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let maybeImage = UIGraphicsGetImageFromCurrentImageContext()
        guard let image = maybeImage, let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage)
        UIGraphicsEndImageContext()
    }
}
