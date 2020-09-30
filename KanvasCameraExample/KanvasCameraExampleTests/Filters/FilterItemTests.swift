//
//  FilterItemTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 11/02/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class FilterItemTests: XCTestCase {
    
    func testFilterColor() {
        let filterType = FilterType.plasma
        let filter = FilterItem(type: .plasma)
        XCTAssertEqual(filter.type, filterType, "Filter type does not match")
    }
}
