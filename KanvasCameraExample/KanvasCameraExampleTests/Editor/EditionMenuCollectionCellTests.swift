//
//  EditionMenuCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 15/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditionMenuCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> EditionMenuCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: EditionMenuCollectionCell.width - 20, height: EditionMenuCollectionCell.height))
        return EditionMenuCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let editionOption = EditionOption.media
        cell.bindTo(editionOption, enabled: false)
        FBSnapshotVerifyView(cell)
    }
}
