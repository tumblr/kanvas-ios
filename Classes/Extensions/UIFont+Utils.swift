//
//  UIFont+Utils.swift
//  KanvasEditor
//
//  Created by Daniela Riesgo on 06/08/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation

/// Extension for simplifying resizing fonts
extension UIFont {

    func withSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(descriptor: self.fontDescriptor, size: fontSize)
    }

}
