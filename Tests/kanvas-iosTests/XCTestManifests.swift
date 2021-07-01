import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(kanvas_iosTests.allTests),
    ]
}
#endif
