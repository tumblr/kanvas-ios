//
//  KanvasCamera+AppColorScheme.swift
//  Orangina
//
//  Created by Brandon Titus on 6/30/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

import Foundation
import KanvasCamera

/// Contains custom colors and fonts for the KanvasCamera framework
public class KanvasCameraCustomUI {
    
   public static let shared = KanvasCameraCustomUI()
            
    private static let brightBlue = UIColor.tumblrBrightBlue
    private static let brightPurple = UIColor.tumblrBrightPurple
    private static let brightPink = UIColor.tumblrBrightPink
    private static let brightYellow = UIColor.tumblrBrightYellow
    private static let brightGreen = UIColor.tumblrBrightGreen
    private static let brightRed = UIColor.tumblrBrightRed
    private static let brightOrange = UIColor.tumblrBrightOrange
    private static let white = UIColor.tumblrWhite
    
    private let pickerColors = [brightBlue,
                         brightBlue,
                         brightPurple,
                         brightPink,
                         brightRed,
                         brightYellow,
                         brightGreen,
                         brightGreen] // ColorPickerView:37
    
    private let segmentColors = [brightBlue,
                                   brightPurple,
                                   brightPink,
                                   brightRed,
                                   brightOrange,
                                   brightYellow,
                                   brightGreen,
                                   brightBlue,
                                   brightPurple,
                                   brightPink,
                                   brightRed,
                                   brightOrange,
                                   brightYellow,
                                   brightGreen,
                                   brightBlue]

    private let backgroundColorCollection = [brightBlue,
                                                         brightPurple,
                                                         brightPink,
                                                         brightRed,
                                                         brightOrange,
                                                         brightYellow,
                                                         brightGreen]
    
    private let mangaColor: UIColor = brightPink
    private let toonColor: UIColor = brightOrange
    
    private let selectedColor = brightBlue // ColorPickerController:29
    private let black25 = UIColor.tumblrBlack25
    
    func cameraColors() -> KanvasCameraColors {
        return KanvasCameraColors(
            drawingDefaultColor: Self.brightBlue,
            colorPickerColors: pickerColors,
            selectedPickerColor: selectedColor,
            timeSegmentColors: segmentColors,
            backgroundColors: backgroundColorCollection,
            strokeColor: Self.brightBlue,
            sliderActiveColor: Self.brightBlue,
            sliderOuterCircleColor: Self.brightBlue,
            trimBackgroundColor: Self.brightBlue,
            trashColor: Self.brightRed,
            tooltipBackgroundColor: .systemRed,
            closeButtonColor: black25,
            filterColors: [
                .manga: mangaColor,
                .toon: toonColor,
            ])
    }
    
    private static let guavaMedium = UIFont.guavaMedium()
    private static let guava85 = UIFont.guava85()
    private static let durianMedium = UIFont.durianMedium()
    
    private static let cameraPermissions = KanvasCameraFonts.CameraPermissions(titleFont: durianMedium, descriptionFont: guava85, buttonFont: guavaMedium)
    private static let drawer = KanvasCameraFonts.Drawer(textSelectedFont: UIFont.favoritTumblrMedium(fontSize: 14), textUnselectedFont: UIFont.favoritTumblr85(fontSize: 14))

    
    func cameraFonts() -> KanvasCameraFonts {
        let paddingAdjustment: (UIFont) -> KanvasCameraFonts.Padding? = { font in
            if font == UIFont.favoritTumblr85(fontSize: font.pointSize) {
                return KanvasCameraFonts.Padding(topMargin: 8.0,
                        leftMargin: 5.7,
                        extraVerticalPadding: 0.125 * font.pointSize,
                        extraHorizontalPadding: 0)
            }
            else {
                return nil
            }
        }
        return KanvasCameraFonts(permissions: Self.cameraPermissions,
                                 drawer: Self.drawer,
                                 editorFonts: [.fairwater(fontSize: 48), UIFont.favoritTumblr85(fontSize: 48)],
                                 playbackCellFont: .guavaMedium(),
                                 mediaClipsFont: UIFont.favoritTumblrMedium(fontSize: 9.5),
                                 modeButtonFont: UIFont.favoritTumblr85(fontSize: 18.5),
                                 speedLabelFont: Self.guavaMedium,
                                 timeIndicatorFont: Self.guavaMedium,
                                 colorSelectorTooltipFont:
                                    UIFont.favoritTumblr85(fontSize: 14),
                                 modeSelectorTooltipFont: UIFont.favoritTumblr85(fontSize: 15),
                                 postLabelFont: UIFont.favoritTumblrMedium(fontSize: 14),
                                 gifMakerRevertButtonFont: UIFont.guavaMedium().fontByAddingSymbolicTrait(.traitBold),
                                 paddingAdjustment: paddingAdjustment
                                 )
    }
}

extension UIFont {
    static func fairwater(fontSize: CGFloat) -> UIFont {
        let font = UIFont(name: "Bradley Hand", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
        if UIFont.isDynamicTypeEnabled {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        return font
    }
    
    @objc func fontByAddingSymbolicTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let modifiedTraits = fontDescriptor.symbolicTraits.union(trait)
        guard let modifiedDescriptor = fontDescriptor.withSymbolicTraits(modifiedTraits) else {
            assertionFailure("Unable to created modified font descriptor by adding a symbolic trait.")
            return self
        }
        return UIFont(descriptor: modifiedDescriptor, size: pointSize)
    }

}
