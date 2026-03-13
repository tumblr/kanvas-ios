//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

public struct KanvasFonts {
    
    private static let guavaMedium = UIFont.systemFont(ofSize: 16) // .guavaMedium
    private static let guava85 = UIFont.systemFont(ofSize: 16) // .guava85
    private static let durianMedium = UIFont.systemFont(ofSize: 16) // .durianMedium
    
    private static func favoritTumblr85(fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    private static func favoritTumblrMedium(fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    static let defaultCameraPermissions = CameraPermissions(titleFont: durianMedium, descriptionFont: guava85, buttonFont: guavaMedium)
    static let defaultDrawer = Drawer(textSelectedFont: KanvasFonts.favoritTumblrMedium(fontSize: 14), textUnselectedFont: KanvasFonts.favoritTumblr85(fontSize: 14))
    
    let paddingAdjustment: ((UIFont) -> Padding?)?
    
    public init(permissions: CameraPermissions,
                drawer: Drawer,
                editorFonts: [UIFont],
                optionSelectorCellFont: UIFont,
                mediaClipsFont: UIFont,
                mediaClipsSmallFont: UIFont,
                modeButtonFont: UIFont,
                speedLabelFont: UIFont,
                timeIndicatorFont: UIFont,
                colorSelectorTooltipFont: UIFont,
                modeSelectorTooltipFont: UIFont,
                postLabelFont: UIFont,
                gifMakerRevertButtonFont: UIFont,
                paddingAdjustment: ((UIFont) -> Padding?)?) {
            self.permissions = permissions
            self.drawer = drawer
            self.editorFonts = editorFonts
            self.optionSelectorCellFont = optionSelectorCellFont
            self.mediaClipsFont = mediaClipsFont
            self.mediaClipsSmallFont = mediaClipsSmallFont
            self.modeButtonFont = modeButtonFont
            self.speedLabelFont = speedLabelFont
            self.timeIndicatorFont = timeIndicatorFont
            self.colorSelectorTooltipFont = colorSelectorTooltipFont
            self.modeSelectorTooltipFont = modeSelectorTooltipFont
            self.postLabelFont = postLabelFont
            self.gifMakerRevertButtonFont = gifMakerRevertButtonFont
            self.paddingAdjustment = paddingAdjustment
    }
    
    public static var shared = KanvasFonts(permissions: defaultCameraPermissions,
                                   drawer: defaultDrawer,
                                   editorFonts: [UIFont.systemFont(ofSize: 48), KanvasFonts.favoritTumblr85(fontSize: 48)],
                                   optionSelectorCellFont: guavaMedium,
                                   mediaClipsFont: KanvasFonts.favoritTumblrMedium(fontSize: 9.5),
                                   mediaClipsSmallFont: KanvasFonts.favoritTumblrMedium(fontSize: 8.5),
                                   modeButtonFont: KanvasFonts.favoritTumblr85(fontSize: 18.5),
                                   speedLabelFont: guavaMedium,
                                   timeIndicatorFont: guavaMedium,
                                   colorSelectorTooltipFont:
                                    KanvasFonts.favoritTumblr85(fontSize: 14),
                                   modeSelectorTooltipFont: KanvasFonts.favoritTumblr85(fontSize: 15),
                                   postLabelFont:
                                    KanvasFonts.favoritTumblrMedium(fontSize: 14),
                                   gifMakerRevertButtonFont: KanvasFonts.guavaMedium,
                                   paddingAdjustment: nil
   )
        
    public struct CameraPermissions {
        public init(titleFont: UIFont,
                    descriptionFont: UIFont,
                    buttonFont: UIFont) {
            self.titleFont = titleFont
            self.descriptionFont = descriptionFont
            self.buttonFont = buttonFont
        }
        let titleFont: UIFont
        let descriptionFont: UIFont
        let buttonFont: UIFont
    }
    
    public struct Drawer {
        public init(textSelectedFont: UIFont, textUnselectedFont: UIFont) {
            self.textSelectedFont = textSelectedFont
            self.textUnselectedFont = textUnselectedFont
        }
        let textSelectedFont: UIFont
        let textUnselectedFont: UIFont // DrawerTabBarCell:29
    }
    
    let permissions: CameraPermissions
    let drawer: Drawer
        
    let editorFonts: [UIFont] // EditorTextController:65
    
    let optionSelectorCellFont: UIFont // OptionSelectorCell:20
    
    let mediaClipsFont: UIFont // MediaClipsCollectionCell:20
    let mediaClipsSmallFont: UIFont // MediaClipsCollectionCell:20
    let modeButtonFont: UIFont // ModeButtonView:24
    
    let speedLabelFont: UIFont // SpeedView.swift:18
    let timeIndicatorFont: UIFont // TimeIndicator.swift:16
    let colorSelectorTooltipFont: UIFont // ColorSelectorView:42
    let modeSelectorTooltipFont: UIFont // ModeSelectorAndShootViewController:18
    let postLabelFont: UIFont // EditorView:438
    let gifMakerRevertButtonFont: UIFont // GifMakerView:188
        
    public struct Padding {
        let topMargin: CGFloat
        let leftMargin: CGFloat
        let extraVerticalPadding: CGFloat
        let extraHorizontalPadding: CGFloat
        
        public init(topMargin: CGFloat,
                    leftMargin: CGFloat,
                    extraVerticalPadding: CGFloat,
                    extraHorizontalPadding: CGFloat) {
            self.topMargin = topMargin
            self.leftMargin = leftMargin
            self.extraVerticalPadding = extraVerticalPadding
            self.extraHorizontalPadding = extraHorizontalPadding
        }
    }    
}
