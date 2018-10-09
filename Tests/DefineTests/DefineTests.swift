import XCTest
@testable import Define

final class DefineTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Define().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
