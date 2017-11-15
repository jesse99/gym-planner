//
//  gym_plannerTests.swift
//  gym-plannerTests
//
//  Created by Jesse Jones on 11/4/17.
//  Copyright © 2017 MushinApps. All rights reserved.
//

import XCTest
@testable import gym_planner

class gym_plannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHistoryLabel() {
        XCTAssertEqual(makeHistoryLabel([]), "")
        XCTAssertEqual(makeHistoryLabel([100.0]), "")
        XCTAssertEqual(makeHistoryLabel([100.0, 100.0]), "same")
        XCTAssertEqual(makeHistoryLabel([100.0, 100.0, 100.0]), "same x2")
        XCTAssertEqual(makeHistoryLabel([100.0, 100.0, 100.0, 110.0]), "+10 lbs, same x2")
        XCTAssertEqual(makeHistoryLabel([100.0, 100.0, 100.0, 110.0, 100.0]), "-10 lbs, +10 lbs, same x2")
    }
            
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
