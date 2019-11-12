//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import UIKit
import GLKit

extension AVAssetTrack {

    var orientation: (orientation: UIImage.Orientation, isPortrait: Bool) {
        let transform = self.preferredTransform
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        }
        else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        }
        else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        }
        else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }

    var glPreferredTransform: GLKMatrix4? {
        switch self.orientation.orientation {
        case .up:
            return nil
        case .down:
            return GLKMatrix4MakeZRotation(.pi)
        case .left:
            return GLKMatrix4MakeZRotation(-.pi/2.0)
        case .right:
            return GLKMatrix4MakeZRotation(.pi/2.0)
        default:
            return nil
        }
    }
}
