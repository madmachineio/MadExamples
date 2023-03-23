import XCTest
@testable import LED

final class LEDTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LED().text, "Hello, World!")
    }
}
