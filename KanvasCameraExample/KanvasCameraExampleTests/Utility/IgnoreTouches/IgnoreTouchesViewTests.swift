//
// Created by Tony Cheng on 8/20/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class IgnoreTouchesViewTests: XCTestCase {

    func newTouchesView() -> IgnoreTouchesView {
        let view = IgnoreTouchesView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        return view
    }

    func testTouchInBounds() {
        let view = newTouchesView()
        let point = CGPoint(x: 20, y: 20)
        let touched = view.hitTest(point, with: nil)
        XCTAssertNil(touched, "The view should ignore touches that are not its subviews")
    }

    func testSubview() {
        let view = newTouchesView()
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.addSubview(subview)
        let point = CGPoint(x: 20, y: 20)
        let touched = view.hitTest(point, with: nil)
        XCTAssertEqual(touched, subview, "The view should return the subview as the receiver")
    }

}
