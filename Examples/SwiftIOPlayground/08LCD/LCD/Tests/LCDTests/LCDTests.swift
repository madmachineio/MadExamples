import XCTest
@testable import LCD

final class LCDTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LCD().text, "Hello, World!")
    }
}
