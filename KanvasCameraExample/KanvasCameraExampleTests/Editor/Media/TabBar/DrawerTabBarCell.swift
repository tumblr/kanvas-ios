//
//  DrawerTabBarCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/11/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DrawerTabBarCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> DrawerTabBarCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: DrawerTabBarCell.width, height: DrawerTabBarCell.height))
        return DrawerTabBarCell(frame: frame)
    }
    
    func testTabBarCell() {
        let cell = newCell()
        let tabBarOption = DrawerTabBarOption.stickers
        cell.bindTo(tabBarOption)
        FBSnapshotVerifyView(cell)
    }
}
