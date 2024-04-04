//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
@testable import Kanvas

final class MediaPickerButtonViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testButtonEnabled() {
        let settings = CameraSettings()
        settings.features.mediaPicking = true
        let view = MediaPickerButtonView(settings: settings)
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        if let image = ResourcePaths.sampleImagePath.flatMap({ UIImage(contentsOfFile: $0) }) {
            view.setThumbnail(image)
        }
        FBSnapshotArchFriendlyVerifyView(view)
    }

    func testButtonDisabled() {
        let settings = CameraSettings()
        settings.features.mediaPicking = false
        let view = MediaPickerButtonView(settings: settings)
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        if let image = ResourcePaths.sampleImagePath.flatMap({ UIImage(contentsOfFile: $0) }) {
            view.setThumbnail(image)
        }
        FBSnapshotArchFriendlyVerifyView(view)
    }

}
