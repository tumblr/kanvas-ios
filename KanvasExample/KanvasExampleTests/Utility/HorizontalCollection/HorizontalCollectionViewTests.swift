//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class HorizontalCollectionViewTests: XCTestCase {
    
    func newView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        return view
    }
    
    func newCollectionView() -> HorizontalCollectionView {
        let frame = CGRect(x: 0, y: 0, width: 320, height: 320)
        let layout = UICollectionViewFlowLayout()
        let collectionView = HorizontalCollectionView(frame: frame, collectionViewLayout: layout, ignoreTouches: true)
        return collectionView
    }
    
    func testIgnoreTouches() {
        let view = newView()
        let collectionView = newCollectionView()
        collectionView.add(into: view)
        let point = CGPoint(x: 20, y: 20)
        let touch = collectionView.hitTest(point, with: nil)
        XCTAssertNil(touch, "The collection view should ignore touches that are not its subviews")
    }
}
