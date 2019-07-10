//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Obtains the next and previous index paths within the current section
extension IndexPath {
    
    func previous() -> IndexPath {
        return IndexPath(item: item - 1, section: section)
    }
    
    func next() -> IndexPath {
        return IndexPath(item: item + 1, section: section)
    }
}
