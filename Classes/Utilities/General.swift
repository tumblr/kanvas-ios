//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/**
 Returns the type's simple name.
 That is to say:
 without scope prefixes,
 without properties' values if it's a struct.
 */
public func SimpleName(ofType type: Any.Type) -> String {
    return String(describing: type)
}

/**
 Returns the concrete type's simple name.
 That is to say:
 without scope prefixes,
 without properties' values if it's a struct.
 
 - seealso: type(of:)
 */
public func SimpleName<T>(of element: T) -> String {
    return SimpleName(ofType: type(of: element as Any))
    // Using as Any to get dynamic type for cases like protocol conforming types.
}
