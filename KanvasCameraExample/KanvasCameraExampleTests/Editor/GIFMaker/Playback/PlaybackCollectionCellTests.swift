//
//  PlaybackCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 29/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class PlaybackCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> PlaybackCollectionCell {
        let frame = CGRect(origin: .zero,
                           size: CGSize(width: 100, height: PlaybackView.height))
        return PlaybackCollectionCell(frame: frame)
    }
    
    func testCell() {
        let cell = newCell()
        cell.bindTo(.loop)
        FBSnapshotVerifyView(cell)
    }
    
    func testSelectedCell() {
        let cell = newCell()
        cell.bindTo(.loop)
        cell.setSelected(true, animated: false)
        FBSnapshotVerifyView(cell)
    }
}
