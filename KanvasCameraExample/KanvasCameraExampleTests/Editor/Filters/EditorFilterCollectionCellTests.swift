//
//  EditorFilterCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 21/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditorFilterCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> EditorFilterCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: EditorFilterCollectionCell.width - 20, height: EditorFilterCollectionCell.minimumHeight))
        return EditorFilterCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filterItem = FilterItem(type: .lightLeaks)
        cell.bindTo(filterItem)
        FBSnapshotVerifyView(cell)
    }
}
