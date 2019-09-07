import XCTest
@testable import OpenParkingDresden

final class OpenParkingDresdenTests: XCTestCase {
    func testExample() throws {
        let data = try Dresden().data()
        XCTAssert(!data.lots.isEmpty)

        for lot in data.lots {
            print(lot)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
