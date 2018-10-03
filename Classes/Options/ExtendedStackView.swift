//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// This is a class that overrides the hit test function to allow for a more tappable area
final class ExtendedStackView: UIStackView {
    
    private let inset: CGFloat
    
    init(inset: CGFloat) {
        self.inset = inset
        super.init(frame: .zero)
    }
    
    @available(*, unavailable, message: "use init(inset:) instead")
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This overridden function returns whether the point for any given event is inside this button's frame
    /// It adds the inset values to the frame, so a negative inset would create an `outset`, and a larger tappable area
    ///
    /// - Parameters:
    ///   - point: The point to test
    ///   - event: UIEvent
    /// - Returns: Bool for whether the point should be recognized by this view
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}
