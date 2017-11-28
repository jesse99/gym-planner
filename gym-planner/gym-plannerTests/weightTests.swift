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
        XCTAssertEqual(w.find(.lower).plates, "no plates")
        XCTAssertEqual(w.find(.closest).plates, "no plates")
        XCTAssertEqual(w.find(.upper).plates, "5 lb plate")
        
        w = Weight(45.0, a)
        XCTAssertEqual(w.find(.lower).plates, "no plates")
        XCTAssertEqual(w.find(.closest).plates, "no plates")
        XCTAssertEqual(w.find(.upper).plates, "5 lb plate")
        
        w = Weight(54.0, a)
        XCTAssertEqual(w.find(.lower).plates, "no plates")
        XCTAssertEqual(w.find(.closest).plates, "5 lb plate")
        XCTAssertEqual(w.find(.upper).plates, "10 lb plate")
        
        w = Weight(56.0, a)
        XCTAssertEqual(w.find(.lower).plates, "no plates")
        XCTAssertEqual(w.find(.closest).plates, "5 lb plate")
        XCTAssertEqual(w.find(.upper).plates, "10 lb plate")
    }

    func testHuge() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: [5, 10, 25, 45, 100], bumpers: [], magnets: [], warmupsWithBar: 2)
        let w = Weight(1014.0, a)
        XCTAssertEqual(w.find(.lower).weight, 1005.0)
        XCTAssertEqual(w.find(.lower).text, "1005 lbs")
        XCTAssertEqual(w.find(.lower).plates, "4 100s + 45 + 25 + 10")
        
        XCTAssertEqual(w.find(.closest).weight, 1015.0)
        XCTAssertEqual(w.find(.closest).text, "1015 lbs")
        XCTAssertEqual(w.find(.closest).plates, "4 100s + 45 + 25 + 10 + 5")
        
        XCTAssertEqual(w.find(.upper).weight, 1025.0)
        XCTAssertEqual(w.find(.upper).text, "1025 lbs")
        XCTAssertEqual(w.find(.upper).plates, "4 100s + 2 45s")
    }

    func testBumpers() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: defaultPlates(), bumpers: defaultBumpers(), magnets: [], warmupsWithBar: 2)
        var w = Weight(0.0, a)
        XCTAssertEqual(w.find(.lower).weight, 75.0)
        XCTAssertEqual(w.find(.lower).text, "75 lbs")
        XCTAssertEqual(w.find(.lower).plates, "15 lb bumper")
        
        XCTAssertEqual(w.find(.closest).weight, 75.0)
        XCTAssertEqual(w.find(.closest).text, "75 lbs")
        XCTAssertEqual(w.find(.closest).plates, "15 lb bumper")
        
        XCTAssertEqual(w.find(.upper).weight, 80)
        XCTAssertEqual(w.find(.upper).text, "80 lbs")
        XCTAssertEqual(w.find(.upper).plates, "15 + 2.5")

        w = Weight(135.0, a)
        XCTAssertEqual(w.find(.lower).weight, 130)
        XCTAssertEqual(w.find(.lower).text, "130 lbs")
        XCTAssertEqual(w.find(.lower).plates, "25 + 15 + 2.5")
        
        XCTAssertEqual(w.find(.closest).weight, 135)
        XCTAssertEqual(w.find(.closest).text, "135 lbs")
        XCTAssertEqual(w.find(.closest).plates, "45 lb bumper")
        
        XCTAssertEqual(w.find(.upper).weight, 140)
        XCTAssertEqual(w.find(.upper).text, "140 lbs")
        XCTAssertEqual(w.find(.upper).plates, "45 + 2.5")
    }
    
    func testMagnets() {
        let a: Apparatus = .barbell(bar: 45.0, collar: 0, plates: [5, 10, 25], bumpers: [], magnets: [0.5, 1.25], warmupsWithBar: 2)
        var w = Weight(0.0, a)
        XCTAssertEqual(w.find(.lower).plates, "no plates")
        XCTAssertEqual(w.find(.closest).plates, "no plates")
        XCTAssertEqual(w.find(.upper).plates, "5 lb plate")     // magnets aren't added to just the bar

        w = Weight(55.0, a)
        XCTAssertEqual(w.find(.lower).plates, "no plates")
        XCTAssertEqual(w.find(.closest).plates, "5 lb plate")
        XCTAssertEqual(w.find(.upper).plates, "5 + 0.5")
        
        w = Weight(56.0, a)
        XCTAssertEqual(w.find(.lower).plates, "5 lb plate")
        XCTAssertEqual(w.find(.closest).plates, "5 + 0.5")
        XCTAssertEqual(w.find(.upper).plates, "5 + 1.25")
        
        w = Weight(57.0, a)
        XCTAssertEqual(w.find(.lower).plates, "5 + 0.5")
        XCTAssertEqual(w.find(.closest).plates, "5 + 1.25")
        XCTAssertEqual(w.find(.upper).plates, "10 lb plate")
        
        w = Weight(61.0, a)
        XCTAssertEqual(w.find(.lower).plates, "5 + 0.5")
        XCTAssertEqual(w.find(.closest).plates, "5 + 1.25")
        XCTAssertEqual(w.find(.upper).plates, "10 lb plate")

        w = Weight(62.0, a)
        XCTAssertEqual(w.find(.lower).plates, "5 + 1.25")
        XCTAssertEqual(w.find(.closest).plates, "10 lb plate")
        XCTAssertEqual(w.find(.upper).plates, "10 + 0.5")
        
        checkRange(a)
    }
    
    private func checkRange(_ a: Apparatus) {
        for i in 100...300 {
            let target = Double(i)
            
            let w = Weight(target, a)
            let lower = w.find(.lower)
            let closest = w.find(.closest)
            let upper = w.find(.upper)
            let text = "target: \(i), lower: \(lower.text), closest: \(closest.text), upper: \(upper.text)"
            
            // We can always find a reasonable lower and upper when we're away from either extreme.
            XCTAssertLessThan(lower.weight, closest.weight, text)
            XCTAssertLessThan(closest.weight, upper.weight, text)
            
            XCTAssertLessThan(lower.weight, target, text)
            XCTAssertGreaterThan(upper.weight, target, text)
            
            XCTAssert(abs(closest.weight - target) < abs(lower.weight - target), text)
            XCTAssert(abs(closest.weight - target) < abs(upper.weight - target), text)
        }
    }
}

