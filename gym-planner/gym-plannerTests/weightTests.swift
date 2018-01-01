import XCTest
@testable import gym_planner

class weightTests: XCTestCase {
    func testRanges() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates:defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 2)
        checkRange(a)
    }
    
    func testTiny() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: [5, 10, 25], bumpers: [], magnets: [], warmupsWithBar: 2)
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().plates, "no plates")
        
        w = Weight(45.0, a)
        XCTAssertEqual(w.closest().plates, "no plates")
        
        w = Weight(54.0, a)
        XCTAssertEqual(w.closest().plates, "5 lb plate")
        
        w = Weight(56.0, a)
        XCTAssertEqual(w.closest().plates, "5 lb plate")
    }

    func testHuge() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: [5, 10, 25, 45, 100], bumpers: [], magnets: [], warmupsWithBar: 2)
        let w = Weight(1014.0, a)
        XCTAssertEqual(w.closest().weight, 1015.0)
        XCTAssertEqual(w.closest().text, "1015 lbs")
        XCTAssertEqual(w.closest().plates, "4 100s + 45 + 25 + 10 + 5")
    }

    func testBumpers() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: defaultPlates(), bumpers: defaultBumpers(), magnets: [], warmupsWithBar: 2)
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().weight, 75.0)
        XCTAssertEqual(w.closest().text, "75 lbs")
        XCTAssertEqual(w.closest().plates, "15 lb bumper")
        
        w = Weight(135.0, a)
        XCTAssertEqual(w.closest().weight, 135)
        XCTAssertEqual(w.closest().text, "135 lbs")
        XCTAssertEqual(w.closest().plates, "45 lb bumper")
    }
    
    func testMagnets() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: [5, 10, 25], bumpers: [], magnets: [0.5, 1.25], warmupsWithBar: 2)
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().plates, "no plates")
        
        w = Weight(55.0, a)
        XCTAssertEqual(w.closest().plates, "5 lb plate")
        
        w = Weight(56.0, a)
        XCTAssertEqual(w.closest().plates, "5 + 0.5")
        
        w = Weight(57.0, a)
        XCTAssertEqual(w.closest().plates, "5 + 1.25")
        
        w = Weight(61.0, a)
        XCTAssertEqual(w.closest().plates, "5 + 1.25")
        
        w = Weight(62.0, a)
        XCTAssertEqual(w.closest().plates, "10 lb plate")
        
        checkRange(a)
    }
    
    func testMachine() {
        let a: Apparatus = .machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().text, "10 lbs")
        
        w = Weight(9.0, a)
        XCTAssertEqual(w.closest().text, "10 lbs")
        
        w = Weight(14.0, a)
        XCTAssertEqual(w.closest().text, "10 lbs")
        
        w = Weight(18.0, a)
        XCTAssertEqual(w.closest().text, "20 lbs")
        
        w = Weight(21.0, a)
        XCTAssertEqual(w.closest().text, "20 lbs")
        
        w = Weight(500.0, a)
        XCTAssertEqual(w.closest().text, "200 lbs")
    }

    func testMachine2() {
        let a: Apparatus = .machine(range1: defaultMachine(), range2: zeroMachine(), extra: [2.5, 5.0])
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().text, "10 lbs")
        
        w = Weight(2.5, a)
        XCTAssertEqual(w.closest().text, "10 lbs")

        w = Weight(9.0, a)
        XCTAssertEqual(w.closest().text, "10 lbs")
        
        w = Weight(12.0, a)
        XCTAssertEqual(w.closest().text, "12.5 lbs")
        
        w = Weight(14.0, a)
        XCTAssertEqual(w.closest().text, "15 lbs")
        
        w = Weight(18.0, a)
        XCTAssertEqual(w.closest().text, "20 lbs")
        
        w = Weight(26.0, a)
        XCTAssertEqual(w.closest().text, "25 lbs")

        w = Weight(500.0, a)
        XCTAssertEqual(w.closest().text, "205 lbs")
    }
    
    func testMachin3() {
        let a: Apparatus = .machine(range1: defaultMachine(), range2: MachineRange(min: 5, max: 20, step: 5), extra: [])
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().text, "5 lbs")
        
        w = Weight(9.0, a)
        XCTAssertEqual(w.closest().text, "10 lbs")
        
        w = Weight(14.0, a)
        XCTAssertEqual(w.closest().text, "15 lbs")
        
        w = Weight(18.0, a)
        XCTAssertEqual(w.closest().text, "20 lbs")
        
        w = Weight(21.0, a)
        XCTAssertEqual(w.closest().text, "20 lbs")
        
        w = Weight(500.0, a)
        XCTAssertEqual(w.closest().text, "200 lbs")
    }
    
    private func checkRange(_ a: Apparatus) {
//        for i in 100...300 {
//            let target = Double(i)
//
//            let w = Weight(target, a)
//            let closest = w.closest()
//            let text = "target: \(i), lower: \(lower.text), closest: \(closest.text), upper: \(upper.text)"
//
//            // We can always find a reasonable lower and upper when we're away from either extreme.
//            XCTAssertLessThan(closest.weight, upper.weight, text)
//        }
    }
}

