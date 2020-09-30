//
//  UIFont+TumblrTheme.swift
//  TumblrTheme
//
//  Created by Benjamin Su on 1/3/19.
//

import Foundation
import UIKit

@objc public extension UIFont {

    static var isDynamicTypeEnabled: Bool = false

    static func favoritTumblrMedium(fontSize: CGFloat) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        if UIFont.isDynamicTypeEnabled {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        return font
    }
    
    static func favoritTumblr85(fontSize: CGFloat) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize)
        if UIFont.isDynamicTypeEnabled {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        else {
            return font
        }
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 64
    static func avocado85() -> UIFont {
        return favoritTumblr85(fontSize: 64)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 48
    static func blueberry85() -> UIFont {
        return favoritTumblr85(fontSize: 48)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 48
    static func blueberryMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 48)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 32
    static func clementine85() -> UIFont {
        return favoritTumblr85(fontSize: 32)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 32
    static func clementineMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 32)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 26
    static func durian85() -> UIFont {
        return favoritTumblr85(fontSize: 26)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 26
    static func durianMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 26)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 21
    static func eggplant85() -> UIFont {
        return favoritTumblr85(fontSize: 21)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 21
    static func eggplantMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 21)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 18
    static func fig85() -> UIFont {
        return favoritTumblr85(fontSize: 18)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 18
    static func figMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 18)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 16
    static func guava85() -> UIFont {
        return favoritTumblr85(fontSize: 16)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 16
    static func guavaMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 16)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 14
    static func honeydew85() -> UIFont {
        return favoritTumblr85(fontSize: 14)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 14
    static func honeydewMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 14)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 12.5
    static func imbe85() -> UIFont {
        return favoritTumblr85(fontSize: 12.5)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 12.5
    static func imbeMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 12.5)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-85 with size of 10
    static func jackfruit85() -> UIFont {
        return favoritTumblr85(fontSize: 10)
    }
    
    /// This returns a UIFont that uses the font family FavoritTumblr-Medium with size of 10
    static func jackfruitMedium() -> UIFont {
        return favoritTumblrMedium(fontSize: 10)
    }
}
