//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

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
    static let retinaScreenMinScale: CGFloat = 2.0
    
    // Device type
    static let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    static let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    // Width and height of current device
    static let screenWidth = Int(UIScreen.main.bounds.size.width)
    static let screenHeight = Int(UIScreen.main.bounds.size.height)
    static let screenMaxLength = Int(max(screenWidth, screenHeight))
    static let screenMinLength = Int(min(screenWidth, screenHeight))
    
    // Device model
    static let isIPhone5 = isIPhone && screenMaxLength == iPhone5ScreenHeight
    static let isIPhone6 = isIPhone && screenMaxLength == iPhone6ScreenHeight
    static let isIPhone6P = isIPhone && screenMaxLength == iPhone6PScreenHeight
    static let isIPhoneX = isIPhone && screenMaxLength == iPhoneXScreenHeight
    static let isIPhoneXS = isIPhone && screenMaxLength == iPhoneXSScreenHeight
    static let isIPhoneXR = isIPhone && screenMaxLength == iPhoneXRScreenHeight
    static let isIPhoneXSMax = isIPhone && screenMaxLength == iPhoneXSMaxScreenHeight
    
    // Device group
    public static let belongsToIPhoneXGroup = isIPhoneX || isIPhoneXR || isIPhoneXS || isIPhoneXSMax
}
