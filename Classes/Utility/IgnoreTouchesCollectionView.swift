//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// CollectionView that transmits touches in the following way:
/// * if the touch was in a subview, the subview responds;
/// * if the touch was in an "empty" space, the touch moves on
/// in the hierarchy of views to some other (parent or brother, or brother's subview)
/// that may respond to that touch.
/// This class is meant to be subclassed.
class IgnoreTouchesCollectionView: UICollectionView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
    
}
