//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension for obtaining a substring from a utf16 range
extension String {

    func substring(withUTF16Range range: NSRange) -> Substring.UTF16View {
        return utf16.prefix(range.upperBound).suffix(range.upperBound - range.lowerBound)
    }

    func copy(withUTF16Range range: NSRange) -> String? {
        return String(substring(withUTF16Range: range))
    }
    
}
