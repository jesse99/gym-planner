import XCTest
@testable import gym_planner

// TODO:
// lower
// upper
// closest
// units, should these be per exercise?
// bodyweight in separate file?
class weightTests: XCTestCase {
//    func testWeight() {
//        let e = Exercise("Bench Press", .barbell(bar: 45, collar: 0, plates: [10, 25], bumpers: [], magnets: []))
//        let w = Weight(100.0)
//        XCTAssertEqual(w.text(.lower, e), "95 lbs")
//    }
    
    func testBarbellGenerator() {
        var a: Apparatus = .barbell(bar: 0, collar: 0, plates: [], bumpers: [], magnets: [], warmupsWithBar: 0)
        var w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "0")
        XCTAssertEqual(w._labels(), "")
        
        a = .barbell(bar: 0, collar: 0, plates: [(2, 5)], bumpers: [], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "5")
        XCTAssertEqual(w._labels(), "5 lb plate")

        // plates
        a = .barbell(bar: 0, collar: 0, plates: [(2, 5), (2, 10), (1, 25)], bumpers: [], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "5, 10, 15")
        XCTAssertEqual(w._labels(), "5 lb plate, 10 lb plate, 10 + 5")

        a = .barbell(bar: 0, collar: 0, plates: [(4, 5), (2, 10)], bumpers: [], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "5, 5, 10, 10, 15, 15, 20")
        XCTAssertEqual(w._labels(), "5 lb plate, 5 lb plate, 10 lb plate, 2 5s, 10 + 5, 10 + 5, 10 + 5 + 5")

        a = .barbell(bar: 0, collar: 0, plates: [(2, 5), (2, 10), (2, 25)], bumpers: [], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "5, 10, 25, 15, 30, 35, 40")
        XCTAssertEqual(w._labels(), "5 lb plate, 10 lb plate, 25 lb plate, 10 + 5, 25 + 5, 25 + 10, 25 + 10 + 5")
        
        // bar
        a = .barbell(bar: 45, collar: 0, plates: [(2, 5)], bumpers: [], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "50")
        XCTAssertEqual(w._labels(), "5 lb plate")

        // collar
        a = .barbell(bar: 45, collar: 5, plates: [(2, 5)], bumpers: [], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "60")
        XCTAssertEqual(w._labels(), "5 lb plate")
        
        // bumpers
        a = .barbell(bar: 0, collar: 0, plates: [(2, 5), (2, 10), (2, 25)], bumpers: [(2, 15)], magnets: [], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "15, 20, 25, 40, 30, 45, 50, 55")
        XCTAssertEqual(w._labels(), "15 lb bumper, 15 + 5, 15 + 10, 25 + 15, 15 + 10 + 5, 25 + 15 + 5, 25 + 15 + 10, 25 + 15 + 10 + 5")

        // magnets
        a = .barbell(bar: 0, collar: 0, plates: [(2, 5), (2, 10)], bumpers: [], magnets: [1.25, 2.5], warmupsWithBar: 0)
        w = Weight(100.0, a)
        XCTAssertEqual(w._weights(), "5, 10, 6.25, 11.25, 7.5, 12.5, 15, 8.75, 13.75, 16.25, 17.5, 18.75")
        XCTAssertEqual(w._labels(), "5 lb plate, 10 lb plate, 5 + 1.25, 10 + 1.25, 5 + 2.5, 10 + 2.5, 10 + 5, 5 + 2.5 + 1.25, 10 + 2.5 + 1.25, 10 + 5 + 1.25, 10 + 5 + 2.5, 10 + 5 + 2.5 + 1.25")
    }
}

