//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import AVFoundation

class FilteredInputViewControllerDelegateStub: FilteredInputViewControllerDelegate {
    func filteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {

    }
}

final class FilteredInputViewControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFilteredInputView() {
        let delegate = FilteredInputViewControllerDelegateStub()
        let settings = CameraSettings()
        let controller = FilteredInputViewController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

}
