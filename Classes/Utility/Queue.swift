//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/**
 * This is an implementation of a Queue data model for enqueueing and dequeueing generics
 **/
struct Queue<Element> {

    private var storage: [Element]

    init() {
        storage = []
    }

    /**
     Initializes the queue with some elements already
     - parameter elements: Represents the elements in the stack.
     The first one is the element at the front of the queue.
     */
    init<T: Collection>(elements: T) where T.Element == Element {
        storage = Array(elements)
    }

    /// Appends element to end of queue
    ///
    /// - Parameter element: element to append
    mutating func enqueue(_ element: Element) {
        storage.append(element)
    }

    /// Returns the first element in queue
    /// (next to dequeue).
    var first: Element? {
        return storage.first
    }

    /// Dequeues the next element if not empty
    ///
    /// - Returns: the dequeued element
    mutating func dequeue() -> Element? {
        guard !storage.isEmpty else { return nil }
        return storage.removeFirst()
    }

    /// Dequeues the next element and then queue it at the end
    ///
    /// - Returns: the optional dequeued (and enqueued) element
    mutating func rotateOnce() -> Element? {
        guard let element = dequeue() else { return nil }
        enqueue(element)
        return element
    }

    /// Checks whether the queue is empty
    var isEmpty: Bool {
        return storage.isEmpty
    }

    /// runs the callback on each element in the queue
    ///
    /// - Parameter callback: the closure for each element
    func forEach(_ callback: (Element) -> ()) {
        storage.forEach(callback)
    }

    /// Returns the number of elements in the queue
    var count: Int {
        return storage.count
    }
}
