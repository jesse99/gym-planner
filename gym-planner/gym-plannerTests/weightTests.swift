import XCTest
@testable import gym_planner

// TODO:
// plates
// bar
// lower
// upper
// closest
// collar
// bumpers
// magnets
// units, should these be per exercise?
// bodyweight in separate file?
class weightTests: XCTestCase {
//    func testWeight() {
//        let e = Exercise("Bench Press", .barbell(bar: 45, collar: 0, plates: [10, 25], bumpers: [], magnets: []))
//        let w = Weight(100.0)
//        XCTAssertEqual(w.text(.lower, e), "95 lbs")
//    }
    
    func testBarbellGenerator() {
        var e = Exercise("Bench Press", .barbell(bar: 0, collar: 0, plates: [(2, 5)], bumpers: [], magnets: []))
        let w = Weight(100.0)
        XCTAssertEqual(w.weights(e), "5.00")
        XCTAssertEqual(w.labels(e), "5 lb plate")

        e = Exercise("Bench Press", .barbell(bar: 0, collar: 0, plates: [(2, 5), (2, 10), (1, 25)], bumpers: [], magnets: []))
        XCTAssertEqual(w.weights(e), "5.00, 10.00, 15.00")
        XCTAssertEqual(w.labels(e), "5 lb plate, 10 lb plate, 10 + 5")

        e = Exercise("Bench Press", .barbell(bar: 0, collar: 0, plates: [(4, 5), (2, 10), (1, 25)], bumpers: [], magnets: []))
        XCTAssertEqual(w.weights(e), "5.00, 5.00, 10.00, 10.00, 15.00, 15.00")
        XCTAssertEqual(w.labels(e), "5 lb plate, 5 lb plate, 10 lb plate, 2 5s, 10 + 5, 10 + 5")
    }
    
    // TODO: might want to have a timed test with a bunch of plates
}

