//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Array {
    
    /// Moves an element inside the array.
    ///
    /// - parameter originIndex: Index at where the element is found before this function
    /// - parameter destinationIndex: Index at where the element is found afetr this function
    /// - warning: Indexes should be valid to use this function.
    mutating func move(from originIndex: Int, to destinationIndex: Int) {
        let element = remove(at: originIndex)
        insert(element, at: destinationIndex)
    }
    
}
