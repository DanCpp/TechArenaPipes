import std.collection.HashMap;

struct PipesCollection {
  var nextID: Int; // Next available Pipe ID
  let pipes: HashMap<Int, Int>; // Pipe ID -> Pipe offset in arena
  var pipes_allocator: PipesAllocator; // Arena allocator for pipes

  public init() {
    pipes = HashMap<Int, Int>();
    pipes_allocator = PipesAllocator();
    nextID = 1; // Start IDs from 1
  }

  func extract(pipeId: Int): (Int, Int) {
    if (pipes.contains(pipeId)) {
      let offset = pipes[pipeId];
      pipes.remove(pipeId);
      // wille be free in arena
      return (pipeId, offset);
    } else {
      return (0, 0); // Pipe not found
    }
  }

  mut func insert(pipeLength: Int): (Int, Int) {
    let pipeId = nextID;
    nextID += 1;
    let (offset, N) = pipes_allocator.allocate(pipeLength); // Allocate space in arena
    pipes[pipeId] = offset;
    
    return (offset, N);
  }
}