import XCTest
@testable import SerialEcho

final class SerialEchoTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SerialEcho().text, "Hello, World!")
    }
}
