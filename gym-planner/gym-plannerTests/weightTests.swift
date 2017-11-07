import XCTest
@testable import gym_planner

class weightTests: XCTestCase {
    func testWeight() {
        let e = Exercise("Bench Press", .barbell(bar: 45.0, plates: [5.0, 10.0, 25.0], bumpers: [], magnets: []))
        let w = Weight(135.0)
        XCTAssertEqual(w.text(.closest, e), "135 lbs")
    }
}

