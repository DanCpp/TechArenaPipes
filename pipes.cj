import std.collection.HashMap;

struct PipesCollection {
  var nextID: Int; 
  let pipes: HashMap<Int, Arena>; // Pipe ID -> offset in arena
  var pipes_allocator: PipesAllocator; 

  public init() {
    pipes = HashMap<Int, Arena>();
    pipes_allocator = PipesAllocator();
    nextID = 1; // Start IDs from 1
  }

  mut func extract(pipeId: Int): (Int, Int) {
    if (pipes.contains(pipeId)) {
      let arena = pipes[pipeId];
      let offset = arena.offset;
      pipes.remove(pipeId);
      pipes_allocator.free(arena);
      return (pipeId, offset);
    } else {
      return (0, 0);
    }
  }

  mut func insert(pipeLength: Int): (Int, Int) {
    let pipeId = nextID;
    nextID += 1;
    let (arena, N) = pipes_allocator.allocate(pipeLength); 
    pipes[pipeId] = arena;
    
    return (arena.offset, N);
  }
}
