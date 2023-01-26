//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the view inside MovableView
protocol MovableViewInnerElement: UIView, NSSecureCoding {
    
    /// Checks whether the hit is done inside the shape of the view
    ///
    /// - Parameter point: location where the view was touched
    /// - Returns: true if the touch was inside, false if not
    func hitInsideShape(point: CGPoint) -> Bool

    var viewSize: CGSize { get set }

    var viewCenter: CGPoint { get set }


}
