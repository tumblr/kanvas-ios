//
//  CameraFilterCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 11/02/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class CameraFilterCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> CameraFilterCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: CameraFilterCollectionCell.width - 20, height: CameraFilterCollectionCell.minimumHeight))
        return CameraFilterCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filterItem = FilterItem(type: .lightLeaks)
        cell.bindTo(filterItem)
        FBSnapshotVerifyView(cell)
    }
}
