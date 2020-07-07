import Foundation
import OpenParking
import SwiftSoup

public class Dresden: Datasource {
    public let name = "Dresden"
    public let slug = "dresden"
    public let infoURL = URL(string: "https://www.dresden.de/parken")!

    let sourceURL = URL(string: "https://apps.dresden.de/ords/f?p=1110")!

    public init() {}

    public func data() throws -> DataPoint {
        let (data, _) = try get(url: self.sourceURL)
        guard let html = String(data: data, encoding: .utf8) else {
            throw OpenParkingError.decoding(description: "Failed to decode HTML", underlyingError: nil)
        }
        let doc = try SwiftSoup.parse(html)
        guard let dateSource = try doc.getElementById("P1_LAST_UPDATE")?
            .text()
            .date(withFormat: .ddMMyyyy_HHmmss)
        else {
            throw OpenParkingError.decoding(description: "Missing date", underlyingError: nil)
        }

        // Select all tables that have a summary field set (a region identifier).
        let lots = try doc.select("table[summary~=.+]")
            .map { region in
                try region.select("tr").compactMap {
                    try extract(lotFrom: $0, region: try region.attr("summary"), dateSource: dateSource)
                }
            }
            .flatMap { $0 }

        return DataPoint(lots: lots)
    }

    private func extract(lotFrom row: Element, region: String, dateSource: Date) throws -> LotResult? {
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
        guard let metadata = geodata.lot(withName: lotName) else {
            return .failure(.missingMetadata(lot: lotName))
        }

        let available = try row.select("td[headers=FREI]").int(else: 0)
        let capacity = try row.select("td[headers=KAPAZITAET]").int() ?? metadata.total

        guard let coordinates = metadata.coordinates else {
            return .failure(.missingMetadataField("coordinates", lot: lotName))
        }

        let typeStr: String = try metadata.value(for: "type")
        guard let type = Lot.LotType(rawValue: typeStr) else {
            throw LotError.other(reason: "Unknown lot type: \(typeStr)")
        }

        let detailURLStr = try row.select("a").attr("href")
        let detailURL = URL(string: "https://apps.dresden.de/ords/\(detailURLStr)")

        return .success(Lot(dataAge: dateSource,
                            name: lotName,
                            coordinates: coordinates,
                            city: self.name,
                            region: region,
                            address: metadata.address,
                            available: .discrete(available),
                            capacity: capacity,
                            state: lotState,
                            type: type,
                            detailURL: detailURL,
                            imageURL: try? metadata.urlValue(for: "image_url"),
                            pricing: Lot.Pricing(url: URL(string: "https://www.dresden.de/apps_ext/HandyParkenApp_de/bookings/booking")!)))
    }
}
