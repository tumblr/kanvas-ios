//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension that checks if a gesture recognizer is currently active/inactive
extension UIGestureRecognizer {
    
    private static let activeStates: [UIGestureRecognizer.State] = [.began, .changed, .recognized]
    private static let inactiveStates: [UIGestureRecognizer.State] = [.ended, .possible, .failed, .cancelled]
    
    var isActive: Bool {
        return UIGestureRecognizer.activeStates.contains(state)
    }
    
    var isInactive: Bool {
        return UIGestureRecognizer.inactiveStates.contains(state)
    }
}
