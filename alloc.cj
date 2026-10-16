import std.collection.LinkedList;
import std.collection.LinkedListNode;
import std.collection.HashMap;

let ARENA_SIZE = 20;

struct PipesAllocator {

  var free_list: LinkedList<(Int, Int)>;
  var allocated: HashMap<Int, Int>; 
  var given_arenas: Int;


  public init() {
    free_list = LinkedList<(Int, Int)>();
    allocated = HashMap<Int, Int>();
    free_list.addLast((0, 0));
    given_arenas = 0;
  }

  mut func allocate(length: Int): (Int, Int) {
    if (free_list.isEmpty()) {
      let new_arenas = expand_free_list(length);
      return (allocate_in_node(free_list.lastNode.getOrThrow(), length), new_arenas);
    }

    var node = free_list.firstNode.getOrThrow();
    while (true) {
      match (node.value) {
        case (offset, free_size) where free_size >= length =>
          return (allocate_in_node(node, length), 0);
        case _ => ();
      }

      match (node.next) {
        case None => break; 
        case Some(next_node) => node = node.next.getOrThrow();
      }
    }

    let new_arenas = expand_free_list(length);
    return (allocate_in_node(free_list.lastNode.getOrThrow(), length), new_arenas);
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
        last.value = (last_offset, last_size + ARENA_SIZE * arenas_needed);
      } else {
        free_list.addLast((new_arena_offset, ARENA_SIZE * arenas_needed));
      }
    }
    given_arenas += arenas_needed;

    return arenas_needed;
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

  mut func free(offset: Int) {
    if (!allocated.contains(offset)) {
      return;
    }

    let length = allocated[offset];
    allocated.remove(offset);

    var prev_node: Option<LinkedListNode<(Int, Int)>> = None;
    var cur_node: Option<LinkedListNode<(Int, Int)>> = free_list.firstNode;
    while (true) {
      match (cur_node) {
        case None => break;
        case Some(cur) =>
          if (cur.value[0] < offset) {
            prev_node = cur_node;
            cur_node = cur.next;
          } else {
            break;
          }
      }
    }
    let canMergeLeft = match (prev_node) {
      case Some(pn) => pn.value[0] + pn.value[1] == offset
      case None => false
    };
    let canMergeRight = match (cur_node) {
      case Some(cn) => cn.value[0] == offset + length
      case None => false
    };

    match ((canMergeLeft, canMergeRight)) {
      case (true, true) =>
        let p = prev_node.getOrThrow();
        let c = cur_node.getOrThrow();
        p.value = (p.value[0], p.value[1] + length + c.value[1]);
        free_list.remove(c);

      case (true, false) =>
        let p = prev_node.getOrThrow();
        p.value = (p.value[0], p.value[1] + length);

      case (false, true) =>
        let c = cur_node.getOrThrow();
        c.value = (offset, length + c.value[1]);

      case (false, false) =>
        match (prev_node) {
          case Some(p) => free_list.addAfter(p, (offset, length))
          case None => free_list.addFirst((offset, length))
        }
    }
  }

}
