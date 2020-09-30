//
//  QueueTests.swift
//  KanvasEditorSDKTests
//
//  Created by Daniela Riesgo on 16/08/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class QueueTests: XCTestCase {

    // MARK: - init and .isEmpty
    func testQueueInitializesEmpty() {
        let queue = Queue<Int>()
        XCTAssert(queue.isEmpty, "Expected new queue to be empty.")
    }

    func testQueueInitializesWithElementsIsNotEmpty() {
        let elements = [1, 2, 3]
        let queue = Queue<Int>(elements: elements)
        XCTAssert(!queue.isEmpty, "Expected queue created with elements to not be empty.")
    }

    func testQueueInitializesWithElementsFirstInSequenceIsFirst() {
        let elements = [1, 2, 3]
        let queue = Queue<Int>(elements: elements)
        XCTAssert(queue.first == 1, "Expected queue created with elements to have first element of sequence as first of queue.")
    }

    // MARK: - .push(element)
    func testEmptyQueueWhenElementEnqueuedNotEmptyAnymore() {
        var queue = Queue<Int>()
        queue.enqueue(2)
        XCTAssert(!queue.isEmpty, "Expected empty queue created to not be empty after new element pushed.")
    }

    // MARK: - .pop()
    func testEmptyQueueWhenDequeuedReturnsNone() {
        var queue = Queue<Int>()
        let value = queue.dequeue()
        XCTAssert(value == .none, "Expected queue.dequeue() on empty queue to return .none, got: \(String(describing: value))")
    }

    func testNotEmptyQueueWhenDequeuedReturnsCorrectValue() {
        let elements = [1, 2, 3]
        var queue = Queue<Int>(elements: elements)
        var value = queue.dequeue()
        var expectedValue = elements.first
        XCTAssert(value == expectedValue, "Expected queue.dequeue() to return first value. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
        value = queue.dequeue()
        expectedValue = elements[1]
        XCTAssert(value == expectedValue, "Expected queue.dequeue() to return top value. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
    }

    func testQueueWhenDequeuedAllValuesIsEmpty() {
        let elements = [1]
        var queue = Queue<Int>(elements: elements)
        let _ = queue.dequeue()
        XCTAssert(queue.isEmpty, "Expected queue to be empty after dequeueing all elements.")
    }

    func testQueueWhenDequeuedNewEnqueuedValueReturnsFirstValue() {
        let elements = [1]
        var queue = Queue<Int>(elements: elements)
        let newElement = 5
        queue.enqueue(newElement)
        let value = queue.dequeue()
        let expectedValue = elements.first
        XCTAssert(value == expectedValue, "Expected value dequeued from queue to equal first enqueued value. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
    }

    // MARK: - .forEach(callback)
    func testForEachIteratesAllValuesInOrder() {
        let elements = [1, 2, 3]
        let queue = Queue<Int>(elements: elements)
        var iteratedElements: [Int] = []
        queue.forEach { iteratedElements.append($0) }
        XCTAssert(iteratedElements == elements, "Expected forEach to provide values in the following order: \(elements), got: \(iteratedElements)")
    }

    // MARK: - .first
    func testEmptyQueueWhenFirstReturnsNone() {
        let queue = Queue<Int>()
        let value = queue.first
        XCTAssert(value == .none, "Expected queue.first on empty queue to return .none, got: \(String(describing: value))")
    }
    
    func testNotEmptyQueueWhenFirstReturnsFirstValue() {
        let elements = [1, 2]
        let queue = Queue<Int>(elements: elements)
        let value = queue.first
        let expectedValue = elements.first
        XCTAssert(value == expectedValue, "Expected queue.first to return first value. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
    }
    
    func testNotEmptyQueueAfterEnqueuedWhenFirstReturnsEnqueuedValue() {
        var queue = Queue<Int>()
        let expectedValue = 7
        queue.enqueue(expectedValue)
        let value = queue.first
        XCTAssert(value == expectedValue, "Expected queue.first to return new queued value. Expected: \(expectedValue) - Got: \(String(describing: value))")
    }
    
    func testNotEmptyQueueAfterDequeuedWhenFirstReturnsNewFirstValue() {
        let elements = [1, 2]
        var queue = Queue<Int>(elements: elements)
        let _ = queue.dequeue()
        let expectedValue = elements[1]
        let value = queue.first
        XCTAssert(value == expectedValue, "Expected queue.first to return new first value after dequeueing. Expected: \(expectedValue) - Got: \(String(describing: value))")
    }
    
    func testFirstOnNotEmptyQueueReturnsFirstValue() {
        let elements = [1, 2]
        let queue = Queue<Int>(elements: elements)
        let value = queue.first
        let expectedValue = elements.first
        XCTAssert(value == expectedValue, "Expected queue.first to return first value. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
    }

    func testFirstOnNotEmptyQueueAfterEnqueuedReturnsEnqueuedValue() {
        var queue = Queue<Int>()
        let expectedValue = 7
        queue.enqueue(expectedValue)
        let value = queue.first
        XCTAssert(value == expectedValue, "Expected queue.first to return new queued value. Expected: \(expectedValue) - Got: \(String(describing: value))")
    }

    func testFirstOnNotEmptyQueueAfterDequeuedReturnsNewFirstValue() {
        let elements = [1, 2]
        var queue = Queue<Int>(elements: elements)
        let _ = queue.dequeue()
        let expectedValue = elements[1]
        let value = queue.first
        XCTAssert(value == expectedValue, "Expected queue.first to return new first value after dequeueing. Expected: \(expectedValue) - Got: \(String(describing: value))")
    }

    // MARK: - .rotateOnce()
    func testRotateOnceOnEmptyQueueMakesNoChanges() {
        var queue = Queue<Int>()
        let _ = queue.rotateOnce()
        XCTAssert(queue.isEmpty, "Expected empty queue to continue empty after .rotateOnce()")
    }

    func testRotateOnceOnOneElementQueueReturnsElementAndNoChanges() {
        let elements = [1]
        var queue = Queue<Int>(elements: elements)
        let expectedValue = elements.first
        var value = queue.rotateOnce()
        XCTAssert(value == expectedValue, "Expected queue.rotateOnce() to return first value before rotating. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
        value = queue.first
        XCTAssert(value == expectedValue, "Expected queue.first to return same first value after rotating. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
    }

    func testQueueRotatedOnceWhenPeekedReturnsNewFirstElementButElementsRamain() {
        let elements = [1,2,3]
        var queue = Queue<Int>(elements: elements)
        var value = queue.rotateOnce()
        var expectedValue = elements[0]
        XCTAssert(value == expectedValue, "Expected queue.rotateOnce() to return first value before rotating. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
        value = queue.first
        expectedValue = elements[1]
        XCTAssert(value == expectedValue, "Expected queue.first to return same first value after rotating. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
        value = queue.count
        expectedValue = elements.count
        XCTAssert(value == expectedValue, "Expected count to return same quantity after rotating. Expected: \(String(describing: expectedValue)) - Got: \(String(describing: value))")
    }

    // MARK: - .numberOfElements()
    func testEmptyQueueHasNoElements() {
        let queue = Queue<Int>()
        XCTAssert(queue.count == 0, "Expected queue.count to be 0 when queue is empty.")

    }

    func testNotEmptyQueueHasElements() {
        let elements = [1,2,3]
        let queue = Queue<Int>(elements: elements)
        let value = queue.count
        let expectedValue = elements.count
        XCTAssert(value == expectedValue, "Expected queue.count to be the same count as elements with which queue was created. Expected: \(expectedValue). Got: \(value).")
    }

    func testQueueHasOneElementMoreWhenEnqueued() {
        let elements = [1,2,3]
        var queue = Queue<Int>(elements: elements)
        queue.enqueue(4)
        let value = queue.count
        let expectedValue = elements.count + 1
        XCTAssert(value == expectedValue, "Expected queue.count to increase by 1 after enqueueing an element. Expected: \(expectedValue). Got: \(value).")
    }

    func testQueueHasOneElementLessWhenDequeued() {
        let elements = [1,2,3]
        var queue = Queue<Int>(elements: elements)
        let _ = queue.dequeue()
        let value = queue.count
        let expectedValue = elements.count - 1
        XCTAssert(value == expectedValue, "Expected queue.count to decrease by 1 after dequeueing an element. Expected: \(expectedValue). Got: \(value).")
    }

}
