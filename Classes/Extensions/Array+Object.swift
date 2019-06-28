//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Array {
    
    /// Returns the object located at the specified index.
    /// If the index is beyond the end of the array, nil is returned.
    ///
    /// - Parameter index: an index within the bounds of the array
    func object(at index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
