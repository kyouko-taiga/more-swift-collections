/// A sorted collection of unique elements.
public struct SortedSet<Element: Comparable> {

  /// The contents of the set.
  private var contents: SortedArray<Element>

  /// Creates an empty array.
  public init() {
    self.contents = []
  }

  /// Creates an instance with the elements in `members`.
  public init<S: Sequence<Element>>(_ members: S) {
    self.init()
    for m in members { self.insert(m) }
  }

  /// `true` iff `self` is empty.
  public var isEmpty: Bool {
    count == 0
  }

  /// The number of elements stored in `self`.
  public var count: Int {
    contents.count
  }

  /// The number of elements that can be stored in `self` without allocating new storage.
  public var capacity: Int {
    contents.capacity
  }

  /// Returns the position of `member` in `self`.
  public func firstIndex(of member: Element) -> Int? {
    let p = contents.insertionIndex(of: member)
    return (p != contents.endIndex) && (contents[p] == member) ? p : nil
  }

  /// Returns `true` iff `member` is contained in `self`.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of `self`.
  public func contains(_ member: Element) -> Bool {
    contents.contains(member)
  }

  /// Adds `member` to `self` if it is not already present and returns `(inserted: i, position: p)`
  /// where `i` is `true` iff the insertion occured and `p` is the position of `member` in `self`.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of `self`.
  @discardableResult
  public mutating func insert(_ member: Element) -> (inserted: Bool, position: Int) {
    contents.insert(member, if: { (s, i) in (i == s.endIndex) || (s[i] != member) })
  }

  /// Removes the element stored at `p`.
  ///
  /// - Requires: `p` is a valid position in `self`.
  @discardableResult
  public mutating func remove(at p: Int) -> Element {
    contents.remove(at: p)
  }

  /// Removes `member` and returns `true` iff it was present; otherwise, returns `false`.
  @discardableResult
  public mutating func remove(_ member: Element) -> Bool {
    let p = contents.insertionIndex(of: member)
    if p != contents.endIndex && contents[p] == member {
      remove(at: p)
      return true
    } else {
      return false
    }
  }

  /// Removes all elements in `self`, preserving storage if `keepCapacity` is `true`.
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    contents.removeAll(keepingCapacity: keepCapacity)
  }

  /// Reserves enough space to store `minimumCapacity` elements without allocating new storage.
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    contents.reserveCapacity(minimumCapacity)
  }

  /// Returns the result of `action` called on the contiguous storage of `self`.
  ///
  /// The pointer passed as an argument to `action` is valid only during the execution of this
  /// method. Do not store or return the pointer for later use. Do not access the sorted array
  /// on which this method is called in `action`. The referenced storage must be sorted according
  /// to the ordering of `Element` when `action` returns.
  ///
  /// - Warning: `action` must not reassign its argument.
  public mutating func withUnsafeMutableBufferPointer<T>(
    _ action: (inout UnsafeMutableBufferPointer<Element>) throws -> T
  ) rethrows -> T? {
    try contents.withUnsafeMutableBufferPointer(action)
  }

}

extension SortedSet: ExpressibleByArrayLiteral {

  /// Creates an instance from an array literal.
  public init(arrayLiteral members: Element...) {
    self.init(members)
  }

}

extension SortedSet: Collection {

  public typealias Index = Int

  /// The position of the first key/value pair in `self`.
  public var startIndex: Int {
    contents.startIndex
  }

  /// The position immediately after the position of the last key/value pair in `self`.
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

extension SortedSet: BidirectionalCollection {

  /// Returns the position immediately before `p`.
  ///
  /// - Requires: `p` is a valid position in `self` and different from `self.startIndex`.
  public func index(before p: Int) -> Int {
    contents.index(before: p)
  }

}

extension SortedSet: Equatable {}

extension SortedSet: Hashable where Element: Hashable {}

extension SortedSet: CustomStringConvertible {

  /// A textual description of `self`.
  public var description: String {
    let members = self.map({ (k) in "\(k)" }).joined(separator: ", ")
    return "[\(members)]"
  }

}
