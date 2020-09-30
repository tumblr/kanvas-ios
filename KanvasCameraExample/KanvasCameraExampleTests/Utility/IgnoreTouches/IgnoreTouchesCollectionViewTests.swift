//
//  IgnoreTouchesCollectionViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 27/11/2018.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class IgnoreTouchesCollectionViewTests: XCTestCase {
    
    func newTouchesCollectionView() -> IgnoreTouchesCollectionView {
        let collectionView = IgnoreTouchesCollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200),
                                                         collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }
    
    func testTouchInBounds() {
        let view = newTouchesCollectionView()
        let point = CGPoint(x: 20, y: 20)
        let touched = view.hitTest(point, with: nil)
        XCTAssertNil(touched, "The collection view should ignore touches that are not its subviews")
    }
    
    func testSubview() {
        let collectionView = newTouchesCollectionView()
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        collectionView.addSubview(subview)
        let point = CGPoint(x: 20, y: 20)
        let touched = collectionView.hitTest(point, with: nil)
        XCTAssertEqual(touched, subview, "The collection view should return the subview as the receiver")
    }
    
}
