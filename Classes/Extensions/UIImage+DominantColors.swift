//
//  UIImage+DominantColors.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 03/07/2019.
//

import Foundation

/// Extension for obtaining the dominant colors of a UIImage
extension UIImage {
    
    /// Gets the dominant colors of an image
    ///
    /// - Parameter count: Number of colors wanted
    /// - Returns: returns a collection with the dominant colors
    func getDominantColors(count: Int) -> [UIColor] {
        guard let colorPalette = ColorThief.getPalette(from: self, colorCount: count, quality: 10, ignoreWhite: false) else {
            return []
        }
        
        return colorPalette.map { $0.makeUIColor() }
    }
}
