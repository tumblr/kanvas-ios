//
//  DeviceTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 05/11/2018.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

/// Tests the Device struct
final class DeviceTests: XCTestCase {

    func testKanvasDevice() {
        XCTAssertEqual(Int(UIScreen.main.bounds.size.height), KanvasDevice.screenHeight, "typealias KanvasDevice isn't working as expected")
    }

    func testDeviceIsIPhone() {
        let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
        XCTAssertEqual(isIPhone, Device.isIPhone, "isIPhone property is not working as expected")
    }
    
    func testDeviceIsIPad() {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        XCTAssertEqual(isIPad, Device.isIPad, "isIPad property is not working as expected")
    }
        
    func testDeviceIsIPhone5() {
        func testDeviceIsIPhoneX() {
            let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
            let screenWidth = Int(UIScreen.main.bounds.size.width)
            let screenHeight = Int(UIScreen.main.bounds.size.height)
            let screenMaxLength = Int(max(screenWidth, screenHeight))
            let isIPhone5 = isIPhone && screenMaxLength == Device.iPhone5ScreenHeight
            
            XCTAssertEqual(isIPhone5, Device.isIPhone5, "isIPhone5 property is not working as expected")
        }
    }
    
    func testDeviceIsIPhone6() {
        func testDeviceIsIPhoneX() {
            let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
            let screenWidth = Int(UIScreen.main.bounds.size.width)
            let screenHeight = Int(UIScreen.main.bounds.size.height)
            let screenMaxLength = Int(max(screenWidth, screenHeight))
            let isIPhone6 = isIPhone && screenMaxLength == Device.iPhone6ScreenHeight
            
            XCTAssertEqual(isIPhone6, Device.isIPhone6, "isIPhone6 property is not working as expected")
        }
    }
    
    func testDeviceIsIPhone6P() {
        func testDeviceIsIPhoneX() {
            let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
            let screenWidth = Int(UIScreen.main.bounds.size.width)
            let screenHeight = Int(UIScreen.main.bounds.size.height)
            let screenMaxLength = Int(max(screenWidth, screenHeight))
            let isIPhone6P = isIPhone && screenMaxLength == Device.iPhone6PScreenHeight
            
            XCTAssertEqual(isIPhone6P, Device.isIPhone6P, "isIPhone6P property is not working as expected")
        }
    }
    
    func testDeviceIsIPhoneX() {
        let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
        let screenWidth = Int(UIScreen.main.bounds.size.width)
        let screenHeight = Int(UIScreen.main.bounds.size.height)
        let screenMaxLength = Int(max(screenWidth, screenHeight))
        let isIPhoneX = isIPhone && screenMaxLength == Device.iPhoneXScreenHeight
        
        XCTAssertEqual(isIPhoneX, Device.isIPhoneX, "isIPhoneX property is not working as expected")
    }
    
}
