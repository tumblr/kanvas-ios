//
//  FilterCollectionInnerCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 21/06/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

private struct CellCustomDimensions: FilterCollectionCellDimensions {
    var circleDiameter: CGFloat = 72
    var circleMaxDiameter: CGFloat = 96.1
    var padding: CGFloat = 0
    var minimumHeight: CGFloat { return circleMaxDiameter }
    var width: CGFloat { return circleMaxDiameter }
}

final class FilterCollectionInnerCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> FilterCollectionInnerCell {
        let dimensions = CellCustomDimensions()
        let cell = FilterCollectionInnerCell(dimensions: dimensions)
        
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100))
        cell.frame = frame
        return cell
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filterItem = FilterItem(type: .lightLeaks)
        cell.bindTo(filterItem)
        FBSnapshotVerifyView(cell)
    }
}
