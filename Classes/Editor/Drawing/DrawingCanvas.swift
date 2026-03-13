//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol DrawingCanvasDelegate: AnyObject {
    func didBeginTouches()
    func didEndTouches()
}

/// View for the drawing tools that shows/hides the menus when touched
final class DrawingCanvas: UIView {
    
    weak var delegate: DrawingCanvasDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didBeginTouches()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didEndTouches()
    }
}
