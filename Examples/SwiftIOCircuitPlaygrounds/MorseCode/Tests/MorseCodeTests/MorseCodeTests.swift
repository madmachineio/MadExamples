import XCTest
@testable import MorseCode

final class MorseCodeTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MorseCode().text, "Hello, World!")
    }
}
