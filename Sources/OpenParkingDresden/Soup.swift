import Foundation
import SwiftSoup

extension Elements {
    func int() throws -> Int? {
        let text = (try? self.text()) ?? ""
        return Int(text)
    }

    func int(else: Int) throws -> Int {
        let text = (try? self.text()) ?? ""
        return Int(text) ?? `else`
    }
}

