/// A sequence prepended by an element.
public struct PrependedSequence<Tail: Sequence> {

  /// The first element in `self`.
  public private(set) var head: Tail.Element

  /// The elements after the first element in `self`.
  public private(set) var tail: Tail

  /// Creates an instance containing `head` followed by all the elements in `tail`.
  public init(_ head: Tail.Element, followedBy tail: Tail) {
    self.head = head
    self.tail = tail
  }

}

extension PrependedSequence: Sequence {

  public typealias Element = Tail.Element

  /// An iterator over the contents of a prepended sequence.
  public struct Iterator: IteratorProtocol {

    /// The head of the iterated sequence, or `nil` if has already been returned.
    private var head: Tail.Element?

    /// The elements left to produce in the tail of the sequence.
    private var tail: Tail.Iterator

    /// Creates an iterator producing `head` followed by the elements in `tail`.
    public init(_ head: Tail.Element, followedBy tail: Tail) {
      self.head = head
      self.tail = tail.makeIterator()
    }

    /// Returns the next element or `nil` if there is none.
    public mutating func next() -> Element? {
      head.take() ?? tail.next()
    }

  }

  /// Returns an iterator over the contents of `self`.
  public func makeIterator() -> Iterator {
    .init(head, followedBy: tail)
  }

}

extension PrependedSequence: Collection where Tail: Collection {

  /// A position in a prepended collection.
  public enum Index: Comparable {

    case head

    case tail(Tail.Index)

    public static func < (l: Self, r: Self) -> Bool {
      switch l {
      case .head:
        return r != .head
      case .tail(let i):
        return if case .tail(let j) = r { i < j } else { false }
      }
    }

  }

  public var startIndex: Index { .head }

  public var endIndex: Index { .tail(tail.endIndex) }

  public func index(after p: Index) -> Index {
    return switch p {
    case .head: .tail(tail.startIndex)
    case .tail(let i): .tail(tail.index(after: i))
    }
  }

  public subscript(p: Index) -> Tail.Element {
    switch p  {
    case .head: head
    case .tail(let i): tail[i]
    }
  }

}

extension PrependedSequence: MutableCollection where Tail: MutableCollection {

  public subscript(p: Index) -> Tail.Element {
    _read {
      switch p {
      case .head: yield head
      case .tail(let i): yield tail[i]
      }
    }
    _modify {
      switch p {
      case .head: yield &head
      case .tail(let i): yield &tail[i]
      }
    }
  }

}

extension PrependedSequence: BidirectionalCollection where Tail: BidirectionalCollection {

  public func index(before p: Index) -> Index {
    switch p {
    case .tail(tail.startIndex):
      return .head
    case .tail(let i):
      return .tail(tail.index(before: i))
    default:
      preconditionFailure("index is out of bounds")
    }
  }

}

extension PrependedSequence: RandomAccessCollection where Tail: RandomAccessCollection {

  public func index(_ p: Index, offsetBy d: Int) -> Index {
    switch p {
    case .head:
      precondition(d >= 0, "index is out of bounds")
      return (d == 0) ? .head : .tail(tail.index(tail.startIndex, offsetBy: d - 1))

    case .tail(let i) where d >= 0:
      return (d == 0) ? .head : .tail(tail.index(i, offsetBy: d))

    case .tail(let i):
      let x = tail.distance(from: tail.startIndex, to: i)
      if d <= x {
        return .tail(tail.index(i, offsetBy: -x))
      } else {
        precondition(x + 1 == -d, "index is out of bounds")
        return .head
      }
    }
  }

}

extension PrependedSequence: Equatable where Tail: Equatable, Tail.Element: Equatable {}

extension PrependedSequence: Hashable where Tail: Hashable, Tail.Element: Hashable {}

extension PrependedSequence: CustomStringConvertible {

  public var description: String {
    var s = "[\(head)"
    for e in tail { s.append(", \(e)") }
    return s + "]"
  }

}

extension PrependedSequence: Sendable where Tail: Sendable, Tail.Element: Sendable {}

extension Sequence {

  /// Returns `self` prepended by `head`.
  public func prepended(with head: Element) -> PrependedSequence<Self> {
    .init(head, followedBy: self)
  }

}
