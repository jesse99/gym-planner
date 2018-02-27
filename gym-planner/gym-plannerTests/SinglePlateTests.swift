import XCTest
@testable import gym_planner

class singlePlateTests: XCTestCase {
    
    func testHuge() {
        let a: Apparatus = .singlePlates(plates: [5, 10, 25, 45, 100])
        let w = Weight(1014.0, a)
        XCTAssertEqual(w.closest().weight, 1015.0)
        XCTAssertEqual(w.closest().text, "1015 lbs")
        XCTAssertEqual(w.closest().plates, "4 100s + 45 + 25 + 10 + 5")
    }
    
    func testDumbbells2() {
        let a: Apparatus = .dumbbells2(weights: [5, 10, 15, 20], magnets: [])
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().weight, 10.0)
        XCTAssertEqual(w.closest().text, "10 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb")
        
        w = Weight(9.0, a)
        XCTAssertEqual(w.closest().weight, 10.0)
        XCTAssertEqual(w.closest().text, "10 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb")
        
        w = Weight(12.0, a)
        XCTAssertEqual(w.closest().weight, 10.0)
        XCTAssertEqual(w.closest().text, "10 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb")
        
        w = Weight(28.0, a)
        XCTAssertEqual(w.closest().weight, 30.0)
        XCTAssertEqual(w.closest().text, "30 lbs")
        XCTAssertEqual(w.closest().plates, "15 lb")
        
        w = Weight(50.0, a)
        XCTAssertEqual(w.closest().weight, 40.0)
        XCTAssertEqual(w.closest().text, "40 lbs")
        XCTAssertEqual(w.closest().plates, "20 lb")
    }
    
    func testDumbbell2Magnets() {
        let a: Apparatus = .dumbbells2(weights: [5, 10, 15, 20], magnets: [0.25, 0.5])
        var w = Weight(0.0, a)
        XCTAssertEqual(w.closest().weight, 10.0)
        XCTAssertEqual(w.closest().text, "10 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb")
        
        w = Weight(9.0, a)
        XCTAssertEqual(w.closest().weight, 10.0)
        XCTAssertEqual(w.closest().text, "10 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb")
        
        w = Weight(10.3, a)
        XCTAssertEqual(w.closest().weight, 10.5)
        XCTAssertEqual(w.closest().text, "10.5 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb + 0.25")
        
        w = Weight(11.0, a)
        XCTAssertEqual(w.closest().weight, 11.0)
        XCTAssertEqual(w.closest().text, "11 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb + 0.5")
        
        w = Weight(12.0, a)
        XCTAssertEqual(w.closest().weight, 11.5)
        XCTAssertEqual(w.closest().text, "11.5 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb + 0.25 + 0.5")
        
        w = Weight(13.0, a)
        XCTAssertEqual(w.closest().weight, 11.5)
        XCTAssertEqual(w.closest().text, "11.5 lbs")
        XCTAssertEqual(w.closest().plates, "5 lb + 0.25 + 0.5")
        
        w = Weight(28.0, a)
        XCTAssertEqual(w.closest().weight, 30.0)
        XCTAssertEqual(w.closest().text, "30 lbs")
        XCTAssertEqual(w.closest().plates, "15 lb")
        
        w = Weight(50.0, a)
        XCTAssertEqual(w.closest().weight, 41.5)
        XCTAssertEqual(w.closest().text, "41.5 lbs")
        XCTAssertEqual(w.closest().plates, "20 lb + 0.25 + 0.5")
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
}


