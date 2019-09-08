import Foundation
import OpenParkingBase
import SwiftSoup

public class Dresden: Datasource {
    public let name = "Dresden"
    public let slug = "dresden"
    public let infoUrl = URL(string: "https://www.dresden.de/parken")!

    let sourceURL = URL(string: "https://apps.dresden.de/ords/f?p=1110")!

    public init() {}

    public func data() throws -> DataPoint {
        let (data, _) = try get(url: self.sourceURL)
        guard let html = String(data: data, encoding: .utf8) else {
            throw OpenParkingError.decoding(description: "Failed to decode HTML", underlyingError: nil)
        }
        let doc = try SwiftSoup.parse(html)
        guard let dateSource = try doc.getElementById("P1_LAST_UPDATE")?.text().date(withFormat: .ddMMyyyy_HHmmss) else {
            throw OpenParkingError.decoding(description: "Missing date", underlyingError: nil)
        }

        // Select all tables that have a summary field set (a region identifier).
        let lots = try doc.select("table[summary~=.+]")
            .filter { try $0.attr("summary") != "Busparkplätze" }
            .map { reg in try reg.select("tr").compactMap { try extract(lotFrom: $0, region: try reg.attr("summary"), dateSource: dateSource) } }
            .flatMap { $0 }

        return DataPoint(lots: lots)
    }

    private func extract(lotFrom row: Element, region: String, dateSource: Date) throws -> Lot? {
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
            throw OpenParkingError.missingMetadata(lot: lotName)
        }

        let free = try row.select("td[headers=FREI]").int(else: 0)
        let total = try row.select("td[headers=KAPAZITAET]").int() ?? metadata["total"]

        guard let coordinate = metadata.coordinate else {
            throw OpenParkingError.missingMetadataField("coordinate", lot: lotName)
        }

        guard let typeStr: String = metadata["type"] else {
            throw OpenParkingError.missingMetadataField("type", lot: lotName)
            // TODO: Does this make sense? This currently breaks off loading of lots and throws the error instead.
            // Wouldn't it make more sense to skip this particular lot, but still load all others?
            // The error in itself is definitely worth the information though, don't want to swallow that. But how to report it?
            // Best thing I can come up with is refactoring DataPoint to not only store lots in its attribute, but lots and specifically these errors.
        }
        let lotKind = Lot.Kind(rawValue: typeStr)

        return Lot(dataAge: dateSource,
                   name: lotName,
                   coordinates: coordinate,
                   city: "Dresden",
                   region: region,
                   address: metadata["address"],
                   free: .discrete(free),
                   total: total,
                   state: lotState,
                   kind: lotKind,
                   detailURL: nil)
    }
}
