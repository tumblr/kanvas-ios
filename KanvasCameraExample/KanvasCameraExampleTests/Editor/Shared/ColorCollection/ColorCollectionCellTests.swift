//
//  ColorCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 02/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorCollectionCellTests: FBSnapshotTestCase {
    
    private let size = 40
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> ColorCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: size, height: size))
        return ColorCollectionCell(frame: frame)
    }
    
    func testColorCell() {
        let cell = newCell()
        let color = UIColor.tumblrBrightBlue
        cell.bindTo(color)
        FBSnapshotVerifyView(cell)
    }
}
