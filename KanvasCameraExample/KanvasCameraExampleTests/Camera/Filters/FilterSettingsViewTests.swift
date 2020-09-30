//
//  FilterSettingsViewTests.swift
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

final class FilterSettingsViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newSettingsView() -> FilterSettingsView {
        let settingsView = FilterSettingsView()
        settingsView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return settingsView
    }
    
    func testIcon() {
        let settingsView = newSettingsView()
        FBSnapshotVerifyView(settingsView)
    }
}
