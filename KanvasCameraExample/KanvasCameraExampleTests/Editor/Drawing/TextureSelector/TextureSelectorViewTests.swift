//
//  TextureSelectorView.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 23/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class TextureSelectorViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> TextureSelectorView {
        let view = TextureSelectorView()
        view.frame = CGRect(x: 0, y: 0,
                            width: TextureSelectorView.selectorWidth,
                            height: TextureSelectorView.selectorHeight)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
}
