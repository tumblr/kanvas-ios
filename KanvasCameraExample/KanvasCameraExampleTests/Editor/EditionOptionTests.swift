//
//  EditionOptionTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 15/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditionOptionTests: XCTestCase {
    
    func testOptionType() {
        let editionOption = EditionOption.media
        XCTAssertEqual(editionOption, .media, "Edition option type does not match")
    }
}
