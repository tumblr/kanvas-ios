//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EasyTipViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        return view
    }
    
    func newSubView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        return view
    }
    
    func newTooltip() -> EasyTipView {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColorCollection = [.tumblrBrightBlue, .tumblrBrightPink]
        preferences.drawing.arrowPosition = .top
        preferences.positioning.margin = 10
        return EasyTipView(text: "Tap to switch modes", preferences: preferences, delegate: nil)
    }
    
    func testShowTooltip() {
        let containerView = newView()
        let subview = newSubView()
        containerView.addSubview(subview)
        
        let tooltip = newTooltip()
        tooltip.show(animated: false, forView: subview, withinSuperview: containerView)
        FBSnapshotVerifyView(containerView)
    }
    
    func testDrawing() {
        var drawing = EasyTipView.Preferences.Drawing()
        drawing.backgroundColorCollection = [.red, .yellow]
        XCTAssertEqual(drawing.backgroundColorCollection, [.red, .yellow], "Colors don't match")
    }
    
    func testPositioning() {
        var positioning = EasyTipView.Preferences.Positioning()
        positioning.margin = 10
        XCTAssertEqual(positioning.margin, 10, "Margin values do not match")
    }
    
    func testAnimating() {
        var animating = EasyTipView.Preferences.Animating()
        animating.showDuration = 1.0
        XCTAssertEqual(animating.showDuration, 1.0, "Duration values do not match")
    }
}
