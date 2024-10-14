import XCTest
import MoreCollections

class SortedArrayTests: XCTestCase {

  func testIsEmpty() {
    var s = SortedArray<Int>()
    XCTAssert(s.isEmpty)
    s.insert(0)
    XCTAssertFalse(s.isEmpty)
  }

  func testCount() {
    var s = SortedArray<Int>()
    XCTAssertEqual(s.count, 0)
    s.insert(0)
    XCTAssertEqual(s.count, 1)
    s.insert(1)
    XCTAssertEqual(s.count, 2)
    s.remove(at: 0)
    XCTAssertEqual(s.count, 1)
  }

  func testInitWithSequence() {
    let s = SortedArray([1, 5, 3])
    XCTAssert(s.elementsEqual([1, 3, 5]))
  }

  func testInitWithArrayLiteral() {
    let s: SortedArray = [1, 5, 3]
    XCTAssert(s.elementsEqual([1, 3, 5]))
  }


  func testContains() {
    var s = SortedArray<Int>()
    XCTAssertFalse(s.contains(42))
    s.insert(42) // insert
    XCTAssert(s.contains(42))
    s.remove(at: 0) // delete
    XCTAssertFalse(s.contains(42))
  }


  func testInsert() {
    var s = SortedArray<Int>()
    XCTAssertEqual(s.insert(0), 0)
    XCTAssertEqual(s.insert(0), 0)
    XCTAssertEqual(s.insert(2), 2)
    XCTAssertEqual(s.insert(1), 2)
  }

  func testInsertIf() {
    var s = SortedArray<Int>()
    XCTAssertEqual(s.insert(0, if: { (_, _) in true }), 0)
    XCTAssertNil(s.insert(0, if: { (_, _) in false }))
    XCTAssertNil(s.insert(1, if: { (t, i) in i < t.endIndex }))
  }

  func testRemoveAt() {
    var s: SortedArray = [1, 5, 3]
    XCTAssertEqual(s.remove(at: 1), 3)
    XCTAssertEqual(Array(s), [1, 5])
  }

  func testRemoveAll() {
    var s: SortedArray = [1, 5, 3]
    s.removeAll()
    XCTAssert(s.isEmpty)

    s.insert(0)
    s.removeAll(keepingCapacity: true)
    XCTAssert(s.isEmpty)
    XCTAssertGreaterThanOrEqual(s.capacity, 1)

    s.insert(0)
    let t = s
    s.removeAll(keepingCapacity: true)
    XCTAssert(t.contains(0))
    XCTAssert(s.isEmpty)
    XCTAssertGreaterThanOrEqual(s.capacity, 1)
  }

  func testReserveCapacity() {
    var s: SortedArray = [1, 5, 3]
    let t = s
    s.reserveCapacity(100)
    XCTAssertEqual(s, t)
    XCTAssertNotEqual(s.capacity, t.capacity)
    XCTAssertGreaterThanOrEqual(s.capacity, 100)
  }

  func testIsValue() {
    let s: SortedArray = [1, 5, 3]
    var t = s
    t.insert(4)
    XCTAssert(s.contains(1))
    XCTAssert(t.contains(1))
  }

  func testIsCollection() {
    let s: SortedArray = [1, 5]
    let i = s.startIndex
    XCTAssertEqual(s[i], 1)
    let j = s.index(after: i)
    XCTAssertEqual(s[j], 5)
    let k = s.index(after: j)
    XCTAssertEqual(k, s.endIndex)
  }

  func testIsBidirectionalCollection() {
    let s: SortedArray = [1, 5]
    let i = s.index(before: s.endIndex)
    XCTAssertEqual(s[i], 5)
    let j = s.index(before: i)
    XCTAssertEqual(s[j], 1)
  }

  func testIsRandomAccessCollection() {
    let s: SortedArray = [1, 5, 3, 7]
    let i = s.index(s.startIndex, offsetBy: 2)
    XCTAssertEqual(i, 2)
    let j = s.index(i, offsetBy: 8, limitedBy: 3)
    XCTAssertNil(j)
  }

  func testIsEquatable() {
    let s: SortedArray = [1, 5, 3]
    let t: SortedArray = [1, 5, 3]
    XCTAssertEqual(s, s)
    XCTAssertEqual(s, t)
    let u: SortedArray = [1, 5, 3, 7]
    XCTAssertNotEqual(s, u)
  }

  func testIsHashable() {
    let s: SortedArray = [1, 5, 3]
    let t: SortedArray = [1, 5, 3]
    XCTAssertEqual(s.hashValue, t.hashValue)
  }

  func testIsCustomStringConvertible() {
    let s: SortedArray = [1, 5, 3]
    XCTAssertEqual(s.description, "[1, 3, 5]")
  }

}
