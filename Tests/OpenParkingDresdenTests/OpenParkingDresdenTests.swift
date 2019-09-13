import XCTest
import OpenParkingDresden
import OpenParkingTests

final class OpenParkingDresdenTests: XCTestCase {
    func testDatasource() throws {
        assert(datasource: Dresden())
    }

    static var allTests = [
        ("testDatasource", testDatasource),
    ]
}
