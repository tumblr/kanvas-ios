//
// Created by Tony Cheng on 8/16/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase

final class KanvasCameraColorsTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testShootButtonBaseColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.shared.shootButtonBaseColor
        
        FBSnapshotVerifyView(view)
    }
}
