//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Image view that increases its image quality when its contentScaleFactor is modified
@objc final class StylableImageView: UIImageView, MovableViewInnerElement, Codable {
    
    let id: String
    
    override var contentScaleFactor: CGFloat {
        willSet {
            setScaleFactor(newValue)
        }
    }

    var viewSize: CGSize = .zero

    var viewCenter: CGPoint = .zero
    
    // MARK: - Initializers
    
    init(id: String, image: UIImage?) {
        self.id = id
        super.init(image: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case size
        case center
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.viewSize = try container.decode(CGSize.self, forKey: .size)
        self.viewCenter = try container.decode(CGPoint.self, forKey: .center)
        super.init(image: nil)
    }

    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(viewSize, forKey: .size)
        try container.encode(viewCenter, forKey: .center)
    }

    // MARK: - Scale factor
    
    /// Sets a new scale factor to update the quality of the inner image. This value represents how content in the view is mapped
    /// from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
    /// For example, if the scale factor is 2.0, 2 pixels will be used to draw each point of the frame.
    ///
    /// - Parameter scaleFactor: the new scale factor. The value will be internally multiplied by the native scale of the device.
    /// Values must be higher than 1.0.
    func setScaleFactor(_ scaleFactor: CGFloat) {
        guard scaleFactor >= 1.0 else { return }
        let scaleFactorForDevice = scaleFactor * UIScreen.main.nativeScale
        for subview in subviews {
            subview.contentScaleFactor = scaleFactorForDevice
        }
    }
    
    // MARK: - MovableViewInnerElement
    
    /// Checks whether the hit is done inside the shape of the view
    ///
    /// - Parameter point: location where the view was touched
    /// - Returns: true if the touch was inside, false if not
    func hitInsideShape(point: CGPoint) -> Bool {
        return layer.getColor(from: point).isVisible()
    }
}
