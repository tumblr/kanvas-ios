//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

//MARK: Default Colors

private let brightBlue = UIColor.systemBlue
private let brightPurple = UIColor.systemPurple
private let brightPink = UIColor.systemPink
private let brightYellow = UIColor.systemYellow
private let brightGreen = UIColor.systemGreen
private let brightRed = UIColor.systemRed
private let brightOrange = UIColor.systemOrange
private let deepBlue = UIColor.systemBlue
private let white = UIColor.white

private let white65 = UIColor(white: 1, alpha: 0.65)
private let black25 = UIColor(white: 0, alpha: 0.25)

private let pickerColors = [brightBlue,
                     brightBlue,
                     brightPurple,
                     brightPink,
                     brightRed,
                     brightYellow,
                     brightGreen,
                     brightGreen]

private let selectedColor = brightBlue

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


// The colors used throughout the module
public struct KanvasColors {
    
    public static var shared: KanvasColors = {
        return KanvasColors(
            drawingDefaultColor: brightBlue,
            colorPickerColors: pickerColors,
            selectedPickerColor: selectedColor,
            timeSegmentColors: segmentColors,
            backgroundColors: backgroundColorCollection,
            strokeColor: brightBlue,
            sliderActiveColor: brightBlue,
            sliderOuterCircleColor: brightBlue,
            trimBackgroundColor: brightBlue,
            trashColor: brightRed,
            tooltipBackgroundColor: .systemRed,
            closeButtonColor: black25,
            cameraConfirmationColor: brightBlue,
            primaryButtonBackgroundColor: brightBlue,
            permissionsButtonColor: UIColor(red: 0, green: 184.0/255.0, blue: 1.0, alpha: 1.0),
            permissionsButtonAcceptedBackgroundColor: UIColor(hex: 0x00cf35),
            overlayColor: deepBlue,
            filterColors: [
                .manga: brightPink,
                .toon: brightOrange,
            ])
    }()
    
    // MARK: - Shooting
    let shootButtonBaseColor: UIColor = .white
    
    // MARK: - Media
    let mediaBorderColor: UIColor = .white
    let mediaSelectedBorderColor: UIColor = .red
    
    // MARK: - Clip collection
    let translucentBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    
    let white: UIColor = .white
    let white65: UIColor = UIColor(white: 1, alpha: 0.65)
    
    public init(
        drawingDefaultColor: UIColor,
        colorPickerColors: [UIColor],
        selectedPickerColor: UIColor,
        timeSegmentColors: [UIColor],
        backgroundColors: [UIColor],
        strokeColor: UIColor,
        sliderActiveColor: UIColor,
        sliderOuterCircleColor: UIColor,
        trimBackgroundColor: UIColor,
        trashColor: UIColor,
        tooltipBackgroundColor: UIColor,
        closeButtonColor: UIColor,
        cameraConfirmationColor: UIColor,
        primaryButtonBackgroundColor: UIColor,
        permissionsButtonColor: UIColor,
        permissionsButtonAcceptedBackgroundColor: UIColor,
        overlayColor: UIColor,
        filterColors: [FilterType: UIColor]) {
        self.drawingDefaultColor = drawingDefaultColor
        self.colorPickerColors = colorPickerColors
        self.selectedPickerColor = selectedPickerColor
        self.timeSegmentColors = timeSegmentColors
        self.backgroundColors = backgroundColors
        self.strokeColor = strokeColor
        self.sliderActiveColor = sliderActiveColor
        self.sliderOuterCircleColor = sliderOuterCircleColor
        self.trimBackgroundColor = trimBackgroundColor
        self.trashColor = trashColor
        self.tooltipBackgroundColor = tooltipBackgroundColor
        self.closeButtonColor = closeButtonColor
        self.cameraConfirmationColor = cameraConfirmationColor
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.permissionsButtonColor = permissionsButtonColor
        self.permissionsButtonAcceptedBackgroundColor = permissionsButtonAcceptedBackgroundColor
        self.overlayColor = overlayColor
        self.filterColors = filterColors
    }

    let permissionsButtonColor: UIColor
    let permissionsButtonAcceptedBackgroundColor: UIColor
    
    let drawingDefaultColor: UIColor // DrawingController:50
    let colorPickerColors: [UIColor] // ColorPickerView:37
    let selectedPickerColor: UIColor // ColorPickerController:29
    let timeSegmentColors: [UIColor] // ShootButtonView:400
    let backgroundColors: [UIColor] // ModeSelectorAndShootView:207
    
    let strokeColor: UIColor //StrokeSelectorView:37
    let sliderActiveColor: UIColor // DiscreteSliderCollectionCell:20
    let sliderOuterCircleColor: UIColor // DiscreteSliderView:280
    let trimBackgroundColor: UIColor // TrimArea:178
    let trashColor: UIColor //TrashView.tintColor
    let tooltipBackgroundColor: UIColor // ColorPickerController:29
    
    let closeButtonColor: UIColor // MediaDrawerView:130
    let cameraConfirmationColor: UIColor
    
    let primaryButtonBackgroundColor: UIColor
    
    let overlayColor: UIColor // EditorView:102
    
    let filterColors: [FilterType: UIColor] // FilterCollectionInnerCell:82
}
