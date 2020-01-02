//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// A representation of a sticker in the media drawer
public struct Sticker {
    
    let imageUrl: String
    
    // MARK: - Initializers
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}
