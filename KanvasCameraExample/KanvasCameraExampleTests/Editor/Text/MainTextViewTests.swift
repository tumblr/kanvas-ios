//
//  MainTextViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 09/09/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class MainTextViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        return view
    }
    
    func testTextViewWithText() {
        let view = newView()
        let textView = MainTextView()
        textView.add(into: view)
        textView.text = "Example"
        textView.textAlignment = .center
        textView.font = .fairwater(fontSize: 48)
        FBSnapshotVerifyView(textView)
    }
}
