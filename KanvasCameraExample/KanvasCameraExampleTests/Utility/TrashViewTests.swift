//
//  TrashViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 03/09/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class TrashViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newTrashView() -> TrashView {
        let trashView = TrashView()
        trashView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        return trashView
    }

    func testShowOpenTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.open()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }
    
    func testShowClosedTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.close()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }
    
    func testOpenAndHideTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.open()
        trashView.hide()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }
    
    func testCloseAndHideTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.close()
        trashView.hide()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }

}
