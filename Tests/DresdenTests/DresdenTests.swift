import XCTest
import Dresden
import OpenParkingTestSupport

final class DresdenTests: XCTestCase {
    func testDatasource() throws {
        validate(datasource: Dresden(), ignoreExceededCapacity: true)
    }
}
