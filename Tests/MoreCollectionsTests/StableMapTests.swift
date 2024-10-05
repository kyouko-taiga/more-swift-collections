import XCTest
import MoreCollections

class StableMapTests: XCTestCase {

  func testIsEmpty() {
    var s = StableMap<String, Int>()
    XCTAssert(s.isEmpty)
    s["a"] = 1
    XCTAssertFalse(s.isEmpty)
  }

  func testCount() {
    var s = StableMap<String, Int>()
    XCTAssertEqual(s.count, 0)
    s["a"] = 100
    XCTAssertEqual(s.count, 1)
    s["b"] = 200
    XCTAssertEqual(s.count, 2)
    s["a"] = nil
    XCTAssertEqual(s.count, 1)
    s["b"] = nil
    XCTAssertEqual(s.count, 0)
  }

  func testInitWithKeyValuePairs() {
    let pairs = [("a", 1), ("b", 2)]
    let s = StableMap<String, Int>(uniqueKeysAndValues: pairs)
    XCTAssert(s.elementsEqual(pairs, by: { (a, b) in (a.0 == b.0) && (a.1 == b.1) }))
  }

  func testInitWithDictionaryLiteral() {
    let pairs = [("a", 1), ("b", 2)]
    let s: StableMap = ["a": 1, "b": 2]
    XCTAssert(s.elementsEqual(pairs, by: { (a, b) in (a.0 == b.0) && (a.1 == b.1) }))
  }

  func testKeySubscript() {
    var s = StableMap<String, Int>()
    s["a"] = 100 // insert
    XCTAssertEqual(s["a"], 100)
    s["a"] = 200 // update
    XCTAssertEqual(s["a"], 200)
    s["a"] = nil // delete
    XCTAssertEqual(s["a"], nil)
    s["a"] = nil // no-op
    XCTAssertEqual(s["a"], nil)
  }

  func testIndexForKey() {
    var s = StableMap<String, Int>()
    XCTAssertNil(s.index(forKey: "a"))

    s["a"] = 1
    XCTAssertEqual(s.index(forKey: "a"), 0)

    s["b"] = 1
    s["c"] = 2
    XCTAssertEqual(s.index(forKey: "a"), 0)
    XCTAssertEqual(s.index(forKey: "b"), 1)
    XCTAssertEqual(s.index(forKey: "c"), 2)

    s["b"] = nil
    XCTAssertEqual(s.index(forKey: "a"), 0)
    XCTAssertNil(s.index(forKey: "b"))
    XCTAssertEqual(s.index(forKey: "c"), 2)
  }

  func testAssignValueForKey() {
    var s = StableMap<String, Int>()

    let p0 = s.assignValue(1, forKey: "a")
    XCTAssert(p0.inserted)
    XCTAssertEqual(p0.position, 0)
    XCTAssertEqual(s[p0.position].value, 1)

    let p1 = s.assignValue(2, forKey: "a")
    XCTAssertFalse(p1.inserted)
    XCTAssertEqual(p1.position, 0)
    XCTAssertEqual(s[p0.position].value, 2)

    let p2 = s.assignValue(2, forKey: "b")
    XCTAssert(p2.inserted)
    XCTAssertEqual(p2.position, 1)
    XCTAssertEqual(s[p2.position].value, 2)
  }

  func testReinsertPair() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    s["b"] = nil
    s["b"] = 200
    XCTAssertEqual(s.index(forKey: "b"), 1)
  }

  func testRemoveAt() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    XCTAssertEqual(s.remove(at: 1).key, "b")
    XCTAssertEqual(s.map(\.key), ["a", "c"])
    XCTAssertEqual(s.remove(at: 2).key, "c")
    XCTAssertEqual(s.map(\.key), ["a"])
  }

  func testRemoveValueForKey() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    XCTAssertEqual(s.removeValue(forKey: "a"), 1)
    XCTAssertNil(s.removeValue(forKey: "a"))
    XCTAssertNil(s.removeValue(forKey: "z"))
  }

  func testRemoveAll() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    s.removeAll()
    XCTAssert(s.isEmpty)

    s["a"] = 1
    s.removeAll(keepingCapacity: true)
    XCTAssert(s.isEmpty)
    XCTAssertGreaterThanOrEqual(s.capacity, 1)

    s["a"] = 1
    let t = s
    s.removeAll(keepingCapacity: true)
    XCTAssertEqual(t["a"], 1)
    XCTAssert(s.isEmpty)
    XCTAssertGreaterThanOrEqual(s.capacity, 1)
  }

  func testReserveCapacity() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    let t = s
    s.reserveCapacity(100)
    XCTAssertEqual(s, t)
    XCTAssertNotEqual(s.capacity, t.capacity)
    XCTAssertGreaterThanOrEqual(s.capacity, 100)
  }

  func testIsValue() {
    let s: StableMap = ["a": 1, "b": 2]
    var t = s
    t["a"] = 3
    XCTAssertEqual(s["a"], 1)
    XCTAssertEqual(t["a"], 3)
  }

  func testIsCollection() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    s.remove(at: 1)

    var i = s.startIndex
    XCTAssert(s[i] == ("a", 1))
    i = s.index(after: i)
    XCTAssert(s[i] == ("c", 3))
    i = s.index(after: i)
    XCTAssertEqual(i, s.endIndex)
  }

  func testIsBidirectionalCollection() {
    var s: StableMap = ["a": 1, "b": 2, "c": 3]
    s.remove(at: 1)

    var i = s.index(before: s.endIndex)
    XCTAssert(s[i] == ("c", 3))
    i = s.index(before: i)
    XCTAssert(s[i] == ("a", 1))
  }

  func testIsEquatable() {
    let s: StableMap = ["a": 1, "b": 2]
    let t: StableMap = ["a": 1, "b": 2]
    XCTAssertEqual(s, s)
    XCTAssertEqual(s, t)
    let u: StableMap = ["b": 2, "a": 1]
    XCTAssertNotEqual(s, u)
  }

  func testIsHashable() {
    let s: StableMap = ["a": 1, "b": 2]
    let t: StableMap = ["a": 1, "b": 2]
    XCTAssertEqual(s.hashValue, t.hashValue)
  }

  func testIsCustomStringConvertible() {
    let s: StableMap = [1: -1, 2: -2]
    XCTAssertEqual(s.description, "[1: -1, 2: -2]")
  }

}
