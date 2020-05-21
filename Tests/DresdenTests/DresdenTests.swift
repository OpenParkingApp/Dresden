import XCTest
import Dresden
import DatasourceValidation

final class DresdenTests: XCTestCase {
    func testDatasource() throws {
        validate(datasource: Dresden())
    }
}
