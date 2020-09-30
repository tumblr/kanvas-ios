//
//  TrimAreaTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class TrimAreaTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> TrimArea {
        let view = TrimArea()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: TrimArea.height)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
    
}
