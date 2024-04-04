//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import Foundation
import UIKit
import XCTest

final class MovableViewCanvasTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> MovableViewCanvas {
        let view = MovableViewCanvas()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        view.backgroundColor = .tumblrBrightBlue
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        let textView = StylableTextView()
        textView.options = TextOptions(text: "Example", font: .fairwater(fontSize: 48))
        let location = view.center
        let transformations =  ViewTransformations()
        view.addView(view: textView, transformations: transformations, location: location, size: view.frame.size, animated: true)
        FBSnapshotArchFriendlyVerifyView(view)
    }
    
    func testMovableTextView() {
        let view = newView()
        let textView = StylableTextView()
        textView.options = TextOptions(text: "Example", font: .fairwater(fontSize: 48))
        let transformations =  ViewTransformations(position: CGPoint(x: 0, y: 300),
                                                   scale: 1.4,
                                                   rotation: 1.2)
        let movableView = MovableView(view: textView, transformations: transformations)
        movableView.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        view.addSubview(movableView)
        movableView.moveToDefinedPosition()
        FBSnapshotArchFriendlyVerifyView(view)
    }
}
