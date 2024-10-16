/// A sorted, random-access collection.
public struct SortedArray<Element: Comparable> {

  /// The contents of the array.
  private var contents: [Element]

  /// Creates an empty array.
  public init() {
    self.contents = []
  }

  /// Creates an instance with the elements in `members`.
  public init<S: Sequence<Element>>(_ members: S) {
    self.contents = members.sorted()
  }

  /// `true` iff `self` is empty.
  public var isEmpty: Bool {
    contents.count == 0
  }

  /// The number of elements stored in `self`.
  public var count: Int {
    contents.count
  }

  /// The number of elements that can be stored in `self` without allocating new storage.
  public var capacity: Int {
    contents.capacity
  }

  /// Returns `true` iff `element` is contained in `self`.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of `self`.
  public func contains(_ element: Element) -> Bool {
    let p = insertionIndex(of: element)
    return (p < contents.count) && (contents[p] == element)
  }

  /// Inserts `newElement` in `self` and returns its position.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of `self`.
  @discardableResult
  public mutating func insert(_ newElement: Element) -> Int {
    let p = insertionIndex(of: newElement)
    contents.insert(newElement, at: p)
    return p
  }

  /// Inserts `newElement` in `self` and returns `(inserted: true, position: p)` iff `predicate(p)`
  /// returns `true`, `p` is the position at whicn `newMember` should be inserted. Otherwise,
  /// returns `(inserted: false, position: p)`.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of `self`.
  @discardableResult
  public mutating func insert(
    _ newElement: Element, if predicate: (Self, Int) throws -> Bool
  ) rethrows -> (inserted: Bool, position: Int) {
    let p = insertionIndex(of: newElement)
    if try predicate(self, p) {
      contents.insert(newElement, at: p)
      return (inserted: true, position: p)
    } else {
      return (inserted: false, position: p)
    }
  }

  /// Returns the position at which `member` could be inserted.
  public func insertionIndex(of element: Element) -> Int {
    var upper = contents.count
    var lower = 0

    while upper > 0 {
      let h = upper >> 1
      let m = lower + h
      if element <= contents[m] {
        upper = h
      } else {
        lower = m + 1
        upper = upper - (h + 1)
      }
    }

    return lower
  }

  /// Removes the element stored at `p`.
  ///
  /// - Requires: `p` is a valid position in `self`.
  @discardableResult
  public mutating func remove(at p: Int) -> Element {
    contents.remove(at: p)
  }

  /// Removes all elements in `self`, preserving storage if `keepCapacity` is `true`.
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    contents.removeAll(keepingCapacity: keepCapacity)
  }

  /// Reserves enough space to store `minimumCapacity` elements without allocating new storage.
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    contents.reserveCapacity(minimumCapacity)
  }

}

extension SortedArray: ExpressibleByArrayLiteral {

  /// Creates an instance from an array literal.
  public init(arrayLiteral members: Element...) {
    self.init(members)
  }

}

extension SortedArray: Collection {

  public typealias Index = Int

  /// The position of the first element in `self`.
  public var startIndex: Int {
    contents.startIndex
  }

  /// The position immediately after the position of the last element in `self`.
  public var endIndex: Int {
    contents.endIndex
  }

  /// Returns the position immediately after `p`.
  ///
  /// - Requires: `p` is a valid position in `self`.
  public func index(after p: Int) -> Int {
    contents.index(after: p)
  }

  /// Accesses the element at `p`.
  ///
  /// - Requires: `p` is a valid position in `self`.
  public subscript(p: Int) -> Element {
    _read { yield contents[p] }
  }

}

extension SortedArray: BidirectionalCollection {

  /// Returns the position immediately before `p`.
  ///
  /// - Requires: `p` is a valid position in `self` and different from `self.startIndex`.
  public func index(before p: Int) -> Int {
    contents.index(before: p)
  }

}

extension SortedArray: RandomAccessCollection {

  /// Returns the position at offset `d` from `p`.
  public func index(_ p: Int, offsetBy d: Int) -> Int {
    contents.index(p, offsetBy: d)
  }

  /// Returns the position at offset `d` from `p`, or `limit` that position is beyond `endIndex`.
  public func index(_ p: Int, offsetBy d: Int, limitedBy limit: Int) -> Int? {
    contents.index(p, offsetBy: d, limitedBy: limit)
  }

}

extension SortedArray: Equatable {}

extension SortedArray: Hashable where Element: Hashable {}

extension SortedArray: CustomStringConvertible {

  /// A textual description of `self`.
  public var description: String {
    contents.description
  }

}
