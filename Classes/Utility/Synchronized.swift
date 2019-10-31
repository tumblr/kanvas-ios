//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Execute `block`, synchronized on `object`.
/// Multiple blocks synchronized on the same `object`,
/// but executing on different threads, will not run at the same time.
func synchronized(_ object: AnyObject, block: () -> Void) {
    objc_sync_enter(object)
    block()
    objc_sync_exit(object)
}

/// Execute `block`, returning an object of type `T`, synchronized on `object`.
/// Multiple blocks synchronized on the same `object`,
/// but executing on different threads, will not run at the same time.
func synchronized<T>(_ object: AnyObject, block: () -> T) -> T {
    objc_sync_enter(object)
    let result: T = block()
    objc_sync_exit(object)
    return result
}
