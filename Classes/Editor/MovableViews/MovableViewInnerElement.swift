//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol MovableViewInnerElement: UIView {
    /// Checks whether the hit is done inside the shape of the view
    ///
    /// - Parameter point: location where the view was touched
    func hitInsideShape(point: CGPoint) -> Bool
}
