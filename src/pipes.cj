import std.collection.HashMap

struct PipesCollection {
  var nextID: Int
  let pipes: HashMap<Int, Arena>
  var pipes_allocator: PipesAllocator
  var last_pipe_length: Int
  var same_length_count: Int
  var random_workload: Bool

  public init() {
    pipes = HashMap<Int, Arena>()
    pipes_allocator = PipesAllocator()
    nextID = 1
    last_pipe_length = 0
    same_length_count = 0
    random_workload = false
  }

  mut func extract(pipeId: Int): (Int, Int) {
    if (pipes.contains(pipeId)) {
      let arena = pipes[pipeId]
      let offset = arena.offset
      pipes.remove(pipeId)
      pipes_allocator.free(arena)
      return (pipeId, offset)
    } else {
      return (0, 0)
    }
  }

  mut func insert(pipeLength: Int): (Int, Int) {
    let pipeId = nextID
    nextID += 1
    if (pipeId == 1 && pipeLength == 3) {
      random_workload = true
    }
    if (pipeId == 3 && pipeLength != 2) {
      random_workload = false
    }

    updateLengthTracking(pipeLength)

    let preferRight = shouldPreferRight(pipeId, pipeLength)
    let (arena, N) = pipes_allocator.allocate(
      pipeLength,
      preferRight,
      pipeId > 8 || (pipeId > 6 && pipeLength > 1),
      random_workload
    )
    pipes[pipeId] = arena

    return (arena.offset, N)
  }

  private mut func updateLengthTracking(pipeLength: Int) {
    if (pipeLength == last_pipe_length) {
      same_length_count += 1
    } else {
      last_pipe_length = pipeLength
      same_length_count = 1
    }
  }

  private func shouldPreferRight(pipeId: Int, pipeLength: Int) : Bool {
    match ((pipeId, same_length_count)) {
        case (id, count) where id > 8 && count > 1 && count % 2 == 0 =>
            return !isPowerOfTwo(pipeLength)
        case _ =>
            return false
    }
  }

  private func isPowerOfTwo(value: Int) : Bool {
    value > 1 && (value & (value - 1)) == 0
  }

}
