//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class TextCanvasTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> TextCanvas {
        let view = TextCanvas()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        view.backgroundColor = .tumblrBrightBlue
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        let options = TextOptions(text: "Example")
        let transformations =  ViewTransformations(position: ViewTransformations.defaultPosition,
                                                   scale: ViewTransformations.defaultScale,
                                                   rotation: ViewTransformations.defaultRotation)
        view.addText(options: options, transformations: transformations, size: view.frame.size)
        FBSnapshotVerifyView(view)
    }
    
    func testMovableTextView() {
        let view = newView()
        let options = TextOptions(text: "Example")
        let transformations =  ViewTransformations(position: CGPoint(x: 0, y: 500),
                                                   scale: 1.4,
                                                   rotation: 1.2)
        let textView = MovableTextView(options: options, transformations: transformations)
        textView.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        view.addSubview(textView)
        FBSnapshotVerifyView(view)
    }
}
