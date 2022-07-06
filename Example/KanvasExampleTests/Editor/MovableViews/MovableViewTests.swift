//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class MovableViewTests: XCTestCase {
    
    func testHitAreaOffsetForBigView() {
        let imageView = StylableImageView(id: "id", image: KanvasImages.gradientImage)
        let movableView = MovableView(view: imageView, transformations: ViewTransformations())
        movableView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        let offset = movableView.calculateHitAreaOffset()
        XCTAssertEqual(offset.height, 0)
        XCTAssertEqual(offset.width, 0)
    }
    
    func testHitAreaOffsetForSmallView() {
        let imageView = StylableImageView(id: "id", image: KanvasImages.gradientImage)
        let movableView = MovableView(view: imageView, transformations: ViewTransformations())
        movableView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        let offset = movableView.calculateHitAreaOffset()
        XCTAssertEqual(offset.height, 40)
        XCTAssertEqual(offset.width, 40)
    }
}
