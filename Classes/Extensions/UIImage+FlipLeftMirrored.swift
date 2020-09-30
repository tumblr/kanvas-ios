//
//  UIImage+FlipLeftMirrored.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 28/12/2018.
//

import UIKit

/// Extension for image flipping
extension UIImage {
    
    /// Rotates an image 90° clockwise and flips it horizontally
    ///
    /// - Returns: a copy of the original UIImage that has been rotated 90° clockwise and flipped horizontally
    public func flipLeftMirrored() -> UIImage? {
        guard let coreGraphicsImage = cgImage else { return nil }
        return UIImage(cgImage: coreGraphicsImage, scale: 1.0, orientation: .leftMirrored)
    }
}
