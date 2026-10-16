import std.collection.HashMap;

struct PipesCollection {
  var nextID: Int; // Next available Pipe ID
  let pipes: HashMap<Int, Int>; // Pipe ID -> Pipe offset in arena

  public init() {
    pipes = HashMap<Int, Int>();
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
    pipes[pipeId] = pipeLength; // will be offset in arena
    // Will be allocation in arena
    return (pipeId, pipeLength);
  }
}