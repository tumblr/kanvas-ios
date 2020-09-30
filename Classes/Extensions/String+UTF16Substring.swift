//
//  String+Subscript.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 04/11/2019.
//

import Foundation
import UIKit

/// Extension for obtaining a substring from a utf16 range
extension String {

    func substring(withUTF16Range range: NSRange) -> Substring.UTF16View {
        return utf16.prefix(range.upperBound).suffix(range.upperBound - range.lowerBound)
    }

    func copy(withUTF16Range range: NSRange) -> String? {
        return String(substring(withUTF16Range: range))
    }
    
}
