//
//  EditorViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 15/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditorViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> EditorView {
        let view = EditorView(mainActionMode: .confirm, showSaveButton: false, showCrossIcon: false, showTagButton: false, quickBlogSelectorCoordinator: nil)
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testFullViewConstraints() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let anotherView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 120))
        anotherView.addSubview(view)
        let fsc = FullViewConstraints(view: view,
                                      top: view.topAnchor.constraint(equalTo: anotherView.topAnchor),
                                      bottom: view.bottomAnchor.constraint(equalTo: anotherView.bottomAnchor),
                                      leading: view.leadingAnchor.constraint(equalTo: anotherView.leadingAnchor),
                                      trailing: view.trailingAnchor.constraint(equalTo: anotherView.trailingAnchor))
        fsc.update(with: CGRect(x: 0, y: 10, width: 100, height: 100))
        XCTAssertEqual(fsc.top.constant, 10)
        XCTAssertEqual(fsc.bottom.constant, -10)
    }
    
}
