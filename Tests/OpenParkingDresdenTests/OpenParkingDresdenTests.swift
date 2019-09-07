import XCTest
@testable import OpenParkingDresden

final class OpenParkingDresdenTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(OpenParkingDresden().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
