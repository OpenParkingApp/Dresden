import XCTest
@testable import OpenParkingDresden

final class OpenParkingDresdenTests: XCTestCase {
    func testExample() {
        let e = expectation(description: "get data")

        Dresden().data { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                e.fulfill()
            case .success(let datapoint):
                XCTAssert(!datapoint.lots.isEmpty)
                for lot in datapoint.lots {
                    print(lot)
                }
                e.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
