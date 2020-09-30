//
//  Device.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 02/11/2018.
//

/// Detects which is the current device using the camera.
/// It also contains useful properties related to the width and height of the device

typealias Device = KanvasDevice

public struct KanvasDevice {
    
    // Dimension and scale constants
    static let iPhone4OrLessScreenMaxHeight = 568
    static let iPhone5ScreenHeight = 568
    static let iPhone6ScreenHeight = 667
    static let iPhone6PScreenHeight = 736
    static let iPhoneXScreenHeight = 812
    static let iPhoneXRScreenHeight = 896
    static let iPhoneXSScreenHeight = 812
    static let iPhoneXSMaxScreenHeight = 896
    static let iPhone11ScreenHeight = 896
    static let iPhone11ProScreenHeight = 812
    static let iPhone11ProMaxScreenHeight = 896
    static let retinaScreenMinScale: CGFloat = 2.0
    
    // Device type
    static let isIPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    static let isIPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    public static let isRunningInSimulator: Bool = TARGET_OS_SIMULATOR != 0
    
    // Width and height of current device
    static let screenWidth: Int = Int(UIScreen.main.bounds.size.width)
    static let screenHeight: Int = Int(UIScreen.main.bounds.size.height)
    static let screenMaxLength: Int = Int(max(screenWidth, screenHeight))
    static let screenMinLength: Int = Int(min(screenWidth, screenHeight))
    
    // Device model
    static let isIPhone5: Bool = isIPhone && screenMaxLength == iPhone5ScreenHeight
    static let isIPhone6: Bool = isIPhone && screenMaxLength == iPhone6ScreenHeight
    static let isIPhone6P: Bool = isIPhone && screenMaxLength == iPhone6PScreenHeight
    static let isIPhoneX: Bool = isIPhone && screenMaxLength == iPhoneXScreenHeight
    static let isIPhoneXS: Bool = isIPhone && screenMaxLength == iPhoneXSScreenHeight
    static let isIPhoneXR: Bool = isIPhone && screenMaxLength == iPhoneXRScreenHeight
    static let isIPhoneXSMax: Bool = isIPhone && screenMaxLength == iPhoneXSMaxScreenHeight
    static let isIPhone11: Bool = isIPhone && screenMaxLength == iPhone11ScreenHeight
    static let isIPhone11Pro: Bool = isIPhone && screenMaxLength == iPhone11ProScreenHeight
    static let isIPhone11ProMax: Bool = isIPhone && screenMaxLength == iPhone11ProMaxScreenHeight
    
    // Device group
    // This group represents all devices which have extra safe space at the top and the bottom, as well as rounded screen corners.
    public static let belongsToIPhoneXGroup: Bool = isIPhoneX || isIPhoneXR || isIPhoneXS || isIPhoneXSMax || isIPhone11 || isIPhone11Pro || isIPhone11ProMax
}
