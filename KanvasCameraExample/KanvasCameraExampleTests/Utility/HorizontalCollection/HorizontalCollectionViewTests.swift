//
//  HorizontalCollectionViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 12/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
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
