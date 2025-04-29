import XCTest
import MoreCollections

class PrependedSequenceTests: XCTestCase {

  func testHeadAndTail() {
    let s = [1, 2, 3].prepended(with: 0)
    XCTAssertEqual(s.head, 0)
    XCTAssertEqual(s.tail, [1, 2, 3])
  }

  func testIsSequence() {
    let s = [1, 2, 3].prepended(with: 0)
    XCTAssert(s.elementsEqual([0, 1, 2, 3]))
  }

  func testIsCollection() {
    let s = [1].prepended(with: 0)
    let i = s.startIndex
    XCTAssertEqual(s[i], 0)
    let j = s.index(after: i)
    XCTAssertEqual(s[j], 1)
    let k = s.index(after: j)
    XCTAssertEqual(k, s.endIndex)
  }

  func testIsBidirectionalCollection() {
    let s = [1].prepended(with: 0)
    let i = s.index(before: s.endIndex)
    XCTAssertEqual(s[i], 1)
    let j = s.index(before: i)
    XCTAssertEqual(s[j], 0)
  }

  func testIsRandomAccessCollection() {
    let s = [1, 2, 3].prepended(with: 0)
    let i = s.index(s.startIndex, offsetBy: 2)
    XCTAssertEqual(s[i], 2)
    let j = s.index(i, offsetBy: 8, limitedBy: s.endIndex)
    XCTAssertNil(j)
  }

  func testIsMutableCollection() {
    var s = [1, 2, 3].prepended(with: 0)
    let i = s.startIndex
    s[i] = 10
    XCTAssertEqual(s.head, 10)

    let j = s.index(after: i)
    s[j] = 10
    XCTAssertEqual(s.tail.first, 10)
  }

  func testIsEquatable() {
    let s = [1, 2, 3].prepended(with: 0)
    let t = [1, 2, 3].prepended(with: 0)
    XCTAssertEqual(s, s)
    XCTAssertEqual(s, t)
    let u = [1, 5, 7].prepended(with: 0)
    XCTAssertNotEqual(s, u)
  }

  func testIsHashable() {
    let s = [1, 2, 3].prepended(with: 0)
    let t = [1, 2, 3].prepended(with: 0)
    XCTAssertEqual(s.hashValue, t.hashValue)
  }

  func testIsCustomStringConvertible() {
    let s = [1, 2, 3].prepended(with: 0)
    XCTAssertEqual(s.description, "[0, 1, 2, 3]")
  }


}
