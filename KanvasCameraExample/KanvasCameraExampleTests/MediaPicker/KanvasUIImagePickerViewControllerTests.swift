//
//  MediaPickerViewControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 7/9/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import Foundation
import XCTest
@testable import KanvasCamera

final class KanvasUIImagePickerViewControllerTests: XCTestCase {

    func testPrefersStatusBarHidden() {
        let c = KanvasUIImagePickerController(nibName: nil, bundle: nil)
        XCTAssert(c.prefersStatusBarHidden == false)
    }

    func testChildForStatusBarHidden() {
        let c = KanvasUIImagePickerController(nibName: nil, bundle: nil)
        XCTAssert(c.childForStatusBarHidden == nil)
    }
}
