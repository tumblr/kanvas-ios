//
//  DrawerTabBarOptionTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/11/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DrawerTabBarOptionTests: XCTestCase {
    
    func testOptionDescription() {
        let option = DrawerTabBarOption.stickers
        XCTAssertEqual(option.description, "Stickers", "Option description does not match")
    }
}
