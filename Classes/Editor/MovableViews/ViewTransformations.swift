//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class ViewTransformations: NSObject, Codable, NSSecureCoding {

    static var supportsSecureCoding: Bool { return true }
    
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

    init?(coder: NSCoder) {
        position = coder.decodeCGPoint(forKey: "position")
        scale = CGFloat(coder.decodeFloat(forKey: "scale"))
        rotation = CGFloat(coder.decodeFloat(forKey: "rotation"))
    }

    func encode(with coder: NSCoder) {
        coder.encode(position, forKey: "position")
        coder.encode(Float(scale), forKey: "scale")
        coder.encode(Float(rotation), forKey: "rotation")
    }
}
