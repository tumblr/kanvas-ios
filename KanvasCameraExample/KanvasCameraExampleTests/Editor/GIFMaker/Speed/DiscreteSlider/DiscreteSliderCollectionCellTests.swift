//
//  DiscreteSliderCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 27/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DiscreteSliderCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newCell() -> DiscreteSliderCollectionCell {
        let size = 36
        let frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        return DiscreteSliderCollectionCell(frame: frame)
    }
        
    func testBeginningCell() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: true, isLast: false)
        FBSnapshotVerifyView(cell)
    }
    
    func testEndingCell() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: true)
        FBSnapshotVerifyView(cell)
    }
    
    func testCellWhenLeftSideIsActive() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: true, rightLineActive: false)
        FBSnapshotVerifyView(cell)
    }
    
    func testCellWhenRightSideIsActive() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: false, rightLineActive: true)
        FBSnapshotVerifyView(cell)
    }
    
    func testInactiveCellOnBothSides() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: false, rightLineActive: false)
        FBSnapshotVerifyView(cell)
    }
    
    func testActiveCellOnBothSides() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: true, rightLineActive: true)
        FBSnapshotVerifyView(cell)
    }
    
    func testCircle() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: true, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: false, rightLineActive: false)
        FBSnapshotVerifyView(cell)
    }
}
