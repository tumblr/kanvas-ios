//
//  ExtendedStackViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Tony Cheng on 10/2/18.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class ExtendedStackViewTests: XCTestCase {
    
    func testTouchOutsideOfStackView() {
        let stackView = ExtendedStackView(inset: -10)
        stackView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        view.addSubview(stackView)
        let touchPoint = CGPoint(x: 5, y: 5)
        let touched = stackView.point(inside: touchPoint, with: nil)
        XCTAssertTrue(touched, "Stack view did not receive touch")
    }
    
}
