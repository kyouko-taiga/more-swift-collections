/// A sorted collection mapping keys to their values.
public struct SortedDictionary<Key: Comparable, Value> {

  /// A bucket in a sorted dictionary.
  fileprivate struct Bucket: Comparable {

    /// The key assigned to this bucket.
    let key: Key

    /// The value assigned to this bucket.
    var value: Value

    /// Returns `true` iff `l` and `r` have the same key.
    public static func == (l: Self, r: Self) -> Bool {
      l.key == r.key
    }

    /// Returns `true` iff `l` is ordered before `r`.
    public static func < (l: Self, r: Self) -> Bool {
      l.key < r.key
    }

  }

  /// The contents of the dictionary.
  private var contents: SortedArray<Bucket>

  /// Creates an empty instance.
  public init() {
    self.contents = []
  }

  /// Creates an empty instance with enough space to store `minimumCapacity` elements without
  /// allocating new storage.
  public init(minimumCapacity: Int) {
    self.init()
    self.reserveCapacity(minimumCapacity)
  }

  /// Creates an instance with the key/value pairs in `keysAndValues`.
  public init<S: Sequence<(Key, Value)>>(uniqueKeysAndValues keysAndValues: S) {
    self.init()
    reserveCapacity(keysAndValues.underestimatedCount)
    for (k, v) in keysAndValues {
      let inserted = assignValue(v, forKey: k).inserted
      precondition(inserted)
    }
  }

  /// `true` iff `self` is empty.
  public var isEmpty: Bool {
    contents.isEmpty
  }

  /// The number of elements stored in `self`.
  public var count: Int {
    contents.count
  }

  /// The number of elements that can be stored in `self` without allocating new storage.
  public var capacity: Int {
    contents.capacity
  }

  /// Accesses the value assigned for `key`.
  public subscript(key: Key) -> Value? {
    _read {
      if let p = index(forKey: key) {
        yield contents[p].value
      } else {
        yield nil
      }
    }

    _modify {
      let p = position(bucketWithKey: key)

      // If the key is not currently contained.
      if (p == contents.endIndex) || (contents[p].key != key) {
        var v: Optional<Value> = nil
        defer {
          if let w = v {
            contents.insert(.init(key: key, value: w))
          }
        }
        yield &v
      }

      // The key is currently contained.
      else {
        var v: Optional = contents[p].value
        defer {
          if let w = v {
            modifyValue(w, at: p)
          } else {
            contents.remove(at: p)
          }
        }
        yield &v
      }
    }
  }

  /// Returns the position of `key` in `self`.
  public func index(forKey key: Key) -> Int? {
    let p = position(bucketWithKey: key)
    if (p == contents.endIndex) || (contents[p].key != key) {
      return nil
    } else {
      return p
    }
  }

  /// Assigns `value` to `key` and returns `(inserted: i, position: p)` where `i` is `true` iff no
  /// value was assigned to `key` and `p` is the position of `key` in `self`.
  @discardableResult
  public mutating func assignValue(
    _ value: Value, forKey key: Key
  ) -> (inserted: Bool, position: Int) {
    let (inserted, p) = contents.insert(.init(key: key, value: value)) {
      (s, p) in (p == s.endIndex) || (s[p].key != key)
    }
    if !inserted { modifyValue(value, at: p) }
    return (inserted, p)
  }

  /// Removes the key/value pair stored at `p`.
  ///
  /// - Requires: `p` is a valid position in `self`.
  @discardableResult
  public mutating func remove(at p: Int) -> (key: Key, value: Value) {
    let b = contents.remove(at: p)
    return (b.key, b.value)
  }

  /// Removes the value assigned to `key` in `self`.
  @discardableResult
  public mutating func removeValue(forKey key: Key) -> Value? {
    if let p = index(forKey: key) {
      return contents.remove(at: p).value
    } else {
      return nil
    }
  }

  /// Removes all key/value pairs in `self`, preserving storage if `keepCapacity` is `true`.
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    contents.removeAll(keepingCapacity: keepCapacity)
  }

  /// Reserves enough space to store `minimumCapacity` elements without allocating new storage.
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    contents.reserveCapacity(minimumCapacity)
  }

  /// Assigns `newValue` to the bucket at position `p`.
  private mutating func modifyValue(_ newValue: Value, at p: Int) {
    contents.withUnsafeMutableBufferPointer { (elements) in
      elements[p].value = newValue
    }
  }

  /// Returns the position at which a bucket with the given `key` should be stored.
  private func position(bucketWithKey key: Key) -> Int {
    withUnsafeTemporaryAllocation(of: Bucket.self, capacity: 1) { (dummy) -> Int in
      let h = MemoryLayout<Bucket>.offset(of: \.key)!
      let k = (UnsafeMutableRawPointer(dummy.baseAddress!) + h).assumingMemoryBound(to: Key.self)
      k.initialize(to: key)
      let p = contents.insertionIndex(of: dummy[0])
      k.deinitialize(count: 1)
      return p
    }
  }

}

extension SortedDictionary: ExpressibleByDictionaryLiteral {

  /// Creates an instance from a dictionary literal.
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysAndValues: elements)
  }

}

extension SortedDictionary: Collection {

  public typealias Element = (key: Key, value: Value)

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

  /// Accesses the key/value pair at `p`.
  ///
  /// - Requires: `p` is a valid position in `self`.
  public subscript(p: Int) -> (key: Key, value: Value) {
    let b = contents[p]
    return (b.key, b.value)
  }

}

extension SortedDictionary: BidirectionalCollection {

  /// Returns the position immediately before `p`.
  ///
  /// - Requires: `p` is a valid position in `self` and different from `self.startIndex`.
  public func index(before p: Int) -> Int {
    contents.index(before: p)
  }

}

extension SortedDictionary: Equatable where Value: Equatable {

  /// Returns `true` iff `l` is equal to `r`.
  public static func == (l: Self, r: Self) -> Bool {
    l.elementsEqual(r) { (a, b) in
      (a.key == b.key) && (a.value == b.value)
    }
  }

}

extension SortedDictionary: Hashable where Key: Hashable, Value: Hashable {

  /// Adds a hash of the salient parts of `self` into `hasher`.
  public func hash(into hasher: inout Hasher) {
    for (k, v) in self {
      hasher.combine(k)
      hasher.combine(v)
    }
  }

}

extension SortedDictionary: CustomStringConvertible {

  /// A textual description of `self`.
  public var description: String {
    let pairs = self.map({ (k, v) in "\(k): \(v)"}).joined(separator: ", ")
    return "[\(pairs)]"
  }

}

extension SortedDictionary: Sendable where Key: Sendable, Value: Sendable {}

extension SortedDictionary.Bucket: Sendable where Key: Sendable, Value: Sendable {}
