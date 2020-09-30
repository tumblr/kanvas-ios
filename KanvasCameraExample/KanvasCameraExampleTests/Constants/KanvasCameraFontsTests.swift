//
//  KanvasCameraFontsTests.swift
//  KanvasCameraExampleTests
//
//  Created by Brandon Titus on 7/7/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
@testable import KanvasCamera

class KanvasCameraFontsTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testDrawerFont() {
        let label = newLabelView()
        let drawer = KanvasCameraFonts.Drawer(textSelectedFont: .guavaMedium(), textUnselectedFont: .guavaMedium())
        label.font = drawer.textSelectedFont
        FBSnapshotVerifyView(label)
    }
    
    func testPermissionsFont() {
        let label = newLabelView()
        let permissions = KanvasCameraFonts.CameraPermissions(titleFont: .guavaMedium(), descriptionFont: .guavaMedium(), buttonFont: .guavaMedium())
        label.font = permissions.titleFont
        FBSnapshotVerifyView(label)
    }
    
    func testPadding() {
        let font = KanvasCameraFonts.shared.postLabelFont
        
        let padding = KanvasCameraFonts.Padding(topMargin: 10, leftMargin: 10, extraVerticalPadding: 10, extraHorizontalPadding: 10)
        XCTAssertEqual(padding.topMargin, 10)
        
        let paddingAdjustment = KanvasCameraFonts.shared.paddingAdjustment?(font)
        XCTAssertNil(paddingAdjustment)
    }
    
    func newLabelView() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = "Test"
        return label
    }
}
