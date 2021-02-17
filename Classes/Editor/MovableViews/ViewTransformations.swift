//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class ViewTransformations: NSObject, NSSecureCoding {

    static var supportsSecureCoding = true
    
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

    private enum CodingKeys: String {
        case position
        case scale
        case rotation
    }

    init?(coder: NSCoder) {
        position = coder.decodeCGPoint(forKey: CodingKeys.position.rawValue)
        scale = CGFloat(coder.decodeFloat(forKey: CodingKeys.scale.rawValue))
        rotation = CGFloat(coder.decodeFloat(forKey: CodingKeys.rotation.rawValue))
    }

    func encode(with coder: NSCoder) {
        coder.encode(position, forKey: CodingKeys.position.rawValue)
        coder.encode(Float(scale), forKey: CodingKeys.scale.rawValue)
        coder.encode(Float(rotation), forKey: CodingKeys.rotation.rawValue)
    }
}
