//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Array where Element: Equatable {
    
    /// Rotates an array to the left
    ///
    /// - Parameter offset: quantity of numbers that will be shifted
    mutating func rotateLeft(offset: Int = 1) {
        let properOffset = offset % count
        let result = self[properOffset...] + self[..<properOffset]
        self = Array(result)
    }
    
    /// Rotates until the sent element is first in the collection
    ///
    /// - Parameter element: the element that will be first in the collection
    mutating func rotate(to element: Element?) {
        guard let element = element,
            let index = firstIndex(where: { $0 == element }) else { return }
        rotateLeft(offset: index)
    }
}
