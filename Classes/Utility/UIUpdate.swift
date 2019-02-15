//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Convenience method to grab the main thread and perform closure
///
/// - Parameter closure: the closure to execute
func performUIUpdate(using closure: @escaping () -> Void) {
    // If we are already on the main thread, execute the closure directly
    if Thread.isMainThread {
        closure()
    }
    else {
        DispatchQueue.main.async(execute: closure)
    }
}

/// Convenience method to access values from the main thread
/// NOTE This method blocks the calling thread.
///
/// - Parameter closure: the closure to execute. Expected to return T.
func accessUISync<T>(using closure: @escaping () -> T) -> T? {
    if Thread.isMainThread {
        return closure()
    }
    var returnValue: T? = nil
    DispatchQueue.main.sync {
        returnValue = closure()
    }
    return returnValue
}

/// Convenience method to grab the main thread and perform closure after a delay
///
/// - Parameters:
///   - deadline: the time in the future to execute
///   - closure: the closure to execute after deadline
func performUIUpdateAfter(deadline: DispatchTime, execute closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: deadline, execute: closure)
}
