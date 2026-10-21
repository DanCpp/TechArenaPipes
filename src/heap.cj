import std.collection.ArrayList

public interface HeapNode {
  func getHeapIndex(): Int
  func setHeapIndex(idx: Int): Unit
}

public class Heap<T> where T <: HeapNode {
  private let items: ArrayList<T>
  private let comp: (T, T) -> Bool

  public init(comp: (T, T) -> Bool) {
    this.items = ArrayList<T>()
    this.comp = comp
  }

  public prop size: Int {
    get() { items.size }
  }

  public prop isEmpty: Bool {
    get() { items.isEmpty() }
  }

  public func peek(): Option<T> {
    if (items.isEmpty()) { return None }
    return Some(items[0])
  }

  public func push(item: T): Unit {
    item.setHeapIndex(items.size)
    items.add(item)
    siftUp(items.size - 1)
  }

  public func pop(): Option<T> {
    if (items.isEmpty()) { return None }
    let top = items[0]
    removeAt(0)
    top.setHeapIndex(-1)
    return Some(top)
  }

  public func remove(item: T): Bool {
    let idx = item.getHeapIndex()
    if (idx < 0 || idx >= items.size) { return false }
    removeAt(idx)
    item.setHeapIndex(-1)
    return true
  }

  private func removeAt(idx: Int): Unit {
    let last = items.size - 1
    if (idx == last) {
      items.remove(at: last)
      return
    }
    swap(idx, last)
    items.remove(at: last)
    if (idx > 0 && comp(items[idx], items[(idx - 1) / 2])) {
      siftUp(idx)
    } else {
      siftDown(idx)
    }
  }

  private func siftUp(start: Int): Unit {
    var i = start
    while (i > 0) {
      let p = (i - 1) / 2
      if (!comp(items[i], items[p])) { break }
      swap(i, p)
      i = p
    }
  }

  private func siftDown(start: Int): Unit {
    var i = start
    let n = items.size
    while (true) {
      let l = 2 * i + 1
      let r = 2 * i + 2
      var smallest = i
      if (l < n && comp(items[l], items[smallest])) { smallest = l }
      if (r < n && comp(items[r], items[smallest])) { smallest = r }
      if (smallest == i) { break }
      swap(i, smallest)
      i = smallest
    }
  }

  private func swap(i: Int, j: Int): Unit {
    let a = items[i]
    let b = items[j]
    items[i] = b
    items[j] = a
    a.setHeapIndex(j)
    b.setHeapIndex(i)
  }
}
