import XCTest
@testable import gym_planner

class storableTests: XCTestCase {
    struct Data: Storable {
        let x: Double
        let n: Int
        let title: String
        
        init(x: Double, n: Int, title: String) {
            self.x = x
            self.n = n
            self.title = title
        }
        
        init(from store: Store) {
            self.x = store.getDbl("x")
            self.n = store.getInt("n")
            self.title = store.getStr("title")
        }
        
        func save(_ store: Store) {
            store.addDbl("x", x)
            store.addInt("n", n)
            store.addStr("title", title)
        }
    }
    
    struct Nested: Storable {
        let a: Data
        let b: Data

        init(first: String, second: String) {
            self.a = Data(x: 10.0, n: 2, title: first)
            self.b = Data(x: 20.0, n: 3, title: second)
        }
        
        init(from store: Store) {
            self.a = store.getObj("a")
            self.b = store.getObj("b")
        }
        
        func save(_ store: Store) {
            store.addObj("a", a)
            store.addObj("b", b)
        }
    }
    
    func testPrimitives() {
        let old = Data(x: 3.14, n: 10, title: "some data")
        
        let store = Store()
        store.addObj("data", old)
        
        let new: Data = store.getObj("data")
        XCTAssert((old.x - new.x) < 0.001)
        XCTAssertEqual(old.n, new.n)
        XCTAssertEqual(old.title, new.title)
    }

    func testIntArray() {
        let old: [Int] = [1, 3, 5, 7]
        
        let store = Store()
        store.addIntArray("data", old)
        
        let new = store.getIntArray("data")
        XCTAssertEqual(old.count, new.count)
        for i in 0..<min(old.count, new.count) {
            XCTAssertEqual(old[i], new[i])
        }
    }

    func testObjArray() {
        let old: [Data] = [Data(x: 3.14, n: 10, title: "some data"), Data(x: 2.718, n: 33, title: "more data")]
        
        let store = Store()
        store.addObjArray("data", old)
        
        let new: [Data] = store.getObjArray("data")
        XCTAssertEqual(old.count, new.count)
        for i in 0..<min(old.count, new.count) {
            XCTAssert((old[i].x - new[i].x) < 0.001)
            XCTAssertEqual(old[i].n, new[i].n)
            XCTAssertEqual(old[i].title, new[i].title)
        }
    }

    func testNested() {
        let old = Nested(first: "one", second: "two")
        
        let store = Store()
        store.addObj("data", old)
        
        let new: Nested = store.getObj("data")
        XCTAssert((old.a.x - new.a.x) < 0.001)
        XCTAssertEqual(old.a.n, new.a.n)
        XCTAssertEqual(old.a.title, new.a.title)

        XCTAssert((old.b.x - new.b.x) < 0.001)
        XCTAssertEqual(old.b.n, new.b.n)
        XCTAssertEqual(old.b.title, new.b.title)
    }
}


