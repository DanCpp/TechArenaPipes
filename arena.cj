import std.collection.LinkedList;
import std.collection.LinkedListNode;
import std.collection.HashMap;

let ARENA_SIZE = 20;

struct PipesAllocator {
  var free_list: LinkedList<(Int, Int)>; // List of free offsets with their lengths
  var allocated: HashMap<Int, Int>; // Map of allocated offsets to their lengths
  var given_arenas: Int;

  public init() {
    free_list = LinkedList<(Int, Int)>();
    allocated = HashMap<Int, Int>();
    free_list.addLast((0, 0)); // Start with an empty arena
    given_arenas = 0;
  }

  private mut func allocate_in_node(node: LinkedListNode<(Int, Int)>, length: Int): Int {
    let allocated_offset = node.value[0];
    let remaining_size = node.value[1] - length;

    if (remaining_size > 0) {
      node.value = (allocated_offset + length, remaining_size);
    } else {
      free_list.remove(node);
    }

    allocated[allocated_offset] = length;
    return allocated_offset;
  }

  private mut func expand_free_list(length: Int): Int {
    let new_arena_offset = given_arenas * ARENA_SIZE;
    let arenas_needed = match (length) {
      case l where l <= ARENA_SIZE => 1
      case _ => 2;
    }

    let last_node = free_list.lastNode;
    if (last_node.isNone()) {
      free_list.addLast((new_arena_offset, ARENA_SIZE * arenas_needed));
    } else {
      let last = last_node.getOrThrow();
      let last_offset = last.value[0];
      let last_size = last.value[1];
      if (last_offset + last_size == new_arena_offset) {
        // Extend the last node
        last.value = (last_offset, last_size + ARENA_SIZE * arenas_needed);
      } else {
        free_list.addLast((new_arena_offset, ARENA_SIZE * arenas_needed));
      }
    }
    given_arenas += arenas_needed;

    return arenas_needed;
  }

  mut func allocate(length: Int): (Int, Int) {
    if (free_list.isEmpty()) {
      let new_arenas = expand_free_list(length);
      return (allocate_in_node(free_list.lastNode.getOrThrow(), length), new_arenas);
    }

    // Find a suitable block in the free list
    var node = free_list.firstNode.getOrThrow();
    while (true) {
      match (node.value) {
        case (offset, free_size) where free_size >= length =>
          return (allocate_in_node(node, length), 0);
        case _ => ();
      }

      match (node.next) {
        case None => break; // No suitable block found
        case Some(next_node) => node = node.next.getOrThrow();
      }
    }

    // If no suitable block found, allocate at the end of the arena
    // Since pipes length is always between 1 and 40, so we can collect new arenas if needed
    let new_arenas = expand_free_list(length);

    // now allocate from the end of the arena
    return (allocate_in_node(free_list.lastNode.getOrThrow(), length), new_arenas);
  }
}