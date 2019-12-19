//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class ViewTransformations {
    
    static let defaultPosition: CGPoint = .zero
    static let defaultScale: CGFloat = 1.0
    static let defaultRotation: CGFloat = 0.0
    
    var position: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    
    init(position: CGPoint = ViewTransformations.defaultPosition,
         scale: CGFloat = ViewTransformations.defaultScale,
         rotation: CGFloat = ViewTransformations.defaultRotation) {
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
    }
}
