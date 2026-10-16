import std.collection.HashMap;

struct PipesCollection {
  var nextID: Int; 
  let pipes: HashMap<Int, Int>; // Pipe ID -> offset in arena
  var pipes_allocator: PipesAllocator; 

  public init() {
    pipes = HashMap<Int, Int>();
    pipes_allocator = PipesAllocator();
    nextID = 1; // Start IDs from 1
  }

  mut func extract(pipeId: Int): (Int, Int) {
    if (pipes.contains(pipeId)) {
      let offset = pipes[pipeId];
      pipes.remove(pipeId);
      pipes_allocator.free(offset);
      return (pipeId, offset);
    
    } else {
      return (0, 0);
    }
  }

  mut func insert(pipeLength: Int): (Int, Int) {
    let pipeId = nextID;
    nextID += 1;
    let (offset, N) = pipes_allocator.allocate(pipeLength); 
    pipes[pipeId] = offset;
    
    return (offset, N);
  }
}
