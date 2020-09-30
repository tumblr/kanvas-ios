//
//  CALayer+ColorTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 03/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class CALayerColorTests: XCTestCase {
    
    private func newView() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        view.backgroundColor = .blue
        return view
    }
    
    func testColor() {
        let view = newView()
        let point = CGPoint(x: 10, y: 10)
        let color = view.layer.getColor(from: point)
        XCTAssertEqual(color, .blue, "Expected color to be blue.")
    }
}
