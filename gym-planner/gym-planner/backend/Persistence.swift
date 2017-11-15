/// Protocol used to save and load data, e.g. settings and history.
import Foundation

// Currently the only arvhive format is json, see http://benscheirman.com/2017/06/ultimate-guide-to-json-parsing-with-swift-4/
// for details.
protocol Persistence {
    func load(_ key: String) throws -> Data
    func save(_ key: String, _ data: Data) throws
}

