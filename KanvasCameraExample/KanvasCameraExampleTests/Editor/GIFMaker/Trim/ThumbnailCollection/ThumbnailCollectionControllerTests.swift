//
//  ThumbnailCollectionControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ThumbnailCollectionControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testThumbnailCollectionControllerView() {
        let controller = ThumbnailCollectionController()
        let delegate = ThumbnailCollectionControllerDelegateStub()
        controller.delegate = delegate
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: ThumbnailCollectionCell.cellHeight)
        controller.view.backgroundColor = .black
        controller.view.setNeedsDisplay()
        
        FBSnapshotVerifyView(controller.view)
    }
}

private class ThumbnailCollectionControllerDelegateStub: ThumbnailCollectionControllerDelegate {
    func getMediaDuration() -> TimeInterval? {
        return TimeInterval(30)
    }
    
    func getThumbnail(at timestamp: TimeInterval) -> UIImage? {
        return KanvasCameraImages.flashOnImage
    }
    
    func didBeginScrolling() {
        
    }
    
    func didScroll() {
        
    }
    
    func didEndScrolling() {
        
    }
}
