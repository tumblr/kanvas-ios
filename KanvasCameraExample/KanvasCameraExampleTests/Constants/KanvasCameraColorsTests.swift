//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
        view.backgroundColor = KanvasCameraColors.shootButtonBaseColor
        
        FBSnapshotVerifyView(view)
    }
    
    func testDreamcastBlueColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.dreamcastBlue
        
        FBSnapshotVerifyView(view)
    }
    
    func testZunePurpleColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.zunePurple
        
        FBSnapshotVerifyView(view)
    }
    
    func testRokrRedColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.rokrRed
        
        FBSnapshotVerifyView(view)
    }
    
    func testSidekickPinkColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.sidekickPink
        
        FBSnapshotVerifyView(view)
    }
    
    func testBetamaxOrangeColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.betamaxOrange
        
        FBSnapshotVerifyView(view)
    }
    
    func testTivoYellowColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.tivoYellow
        
        FBSnapshotVerifyView(view)
    }
    
    func testGlassGreenColor() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = KanvasCameraColors.glassGreen
        
        FBSnapshotVerifyView(view)
    }
}
