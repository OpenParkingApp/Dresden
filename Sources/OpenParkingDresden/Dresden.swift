import Foundation
import OpenParkingBase
import SwiftSoup

public class Dresden: Datasource {
    public let name = "Dresden"
    public let slug = "dresden"
    public let infoUrl = URL(string: "https://www.dresden.de/parken")!

    public var attribution: Attribution? = nil

    let sourceURL = URL(string: "https://apps.dresden.de/ords/f?p=1110")!

    public func data(completion: @escaping (Result<DataPoint, OpenParkingError>) -> Void) {
        get(url: self.sourceURL) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (data, _)):
                guard let html = String(data: data, encoding: .utf8) else {
                    completion(.failure(.decoding(description: "Failed to decode html", underlyingError: nil)))
                    return
                }
                do {
                    let datapoint = try self.parse(html: html)
                    completion(.success(datapoint))
                } catch {
                    completion(.failure(.decoding(description: "SwiftSoup error", underlyingError: error)))
                }
            }
        }
    }

    public func parse(html: String) throws -> DataPoint {
        let doc = try SwiftSoup.parse(html)
        let dateSource = try doc.getElementById("P1_LAST_UPDATE")?.text().date(withFormat: .ddMMyyyy_HHmmss)

        // Select all tables that have a summary field set (a region identifier).
        let lots = try doc.select("table[summary~=.+]")
            .filter { try $0.attr("summary") != "Busparkplätze" }
            .map { try $0.select("tr").compactMap(extract(lotFrom:)) }
            .flatMap { $0 }

        return DataPoint(dateSource: dateSource, lots: lots)
    }

    private func extract(lotFrom row: Element) throws -> Lot? {
        // Ignore section headers.
        guard try row.select("th").isEmpty() else { return nil }

        var lotState = Lot.State.open
        let imageDivClass = try row.select("div").attr("class")
        // green, yellow and red are open, blue is no data, park-closed is... closed
        if imageDivClass.contains("park-closed") {
            lotState = .closed
        } else if imageDivClass.contains("blue") {
            lotState = .noData
        }

        let lotName = try row.select("td[headers=BEZEICHNUNG]").text()
        let free = try row.select("td[headers=FREI]").int(else: 0)
        // TODO: Get fallback from geodata instead.
        // Or maybe put that and coordinate lookup into Lot initializer when params are nil?
        let total = try row.select("td[headers=KAPAZITAET]").int()

        return Lot(name: lotName,
                   coordinates: Coordinates(lat: 1.0, lng: 1.0),
                   city: "Dresden",
                   region: nil,
                   address: nil,
                   free: .discrete(free),
                   total: total,
                   state: lotState,
                   type: nil,
                   detailURL: nil)
    }
}
