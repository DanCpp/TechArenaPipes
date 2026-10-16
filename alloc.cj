import std.collection.ArrayList;

public class Arena {
  public var offset: Int;
  public var size: Int;
  public var is_free: Bool;

  public var left: Option<Arena> = None;
  public var right: Option<Arena> = None;

  public var prev_free: Option<Arena> = None;
  public var next_free: Option<Arena> = None;

  public init(offset: Int, size: Int, is_free: Bool) {
    this.offset = offset;
    this.size = size;
    this.is_free = is_free;
  }

  public prop end: Int {
    get() {
      return offset + size - 1;
    }
  }
}

public class PipesAllocator {
  var free_heads: ArrayList<Option<Arena>>;
  var large_head: Option<Arena> = None;

  var first_arena: Option<Arena> = None;
  var last_arena: Option<Arena> = None;

  public init() {
    free_heads = ArrayList<Option<Arena>>(41);
    var i = 0;
    while (i < 41) {
      free_heads.add(None);
      i += 1;
    }
  }

  private func add_to_free(arena: Arena): Unit {
    arena.is_free = true;
    arena.prev_free = None;

    if (arena.size <= 40) {
      let head = free_heads[arena.size];
      arena.next_free = head;
      if (let Some(h) <- head) {
        h.prev_free = Some(arena);
      }
      free_heads[arena.size] = Some(arena);
    } else {
      arena.next_free = large_head;
      if (let Some(h) <- large_head) {
        h.prev_free = Some(arena);
      }
      large_head = Some(arena);
    }
  }

  private func remove_from_free(arena: Arena): Unit {
    let prev = arena.prev_free;
    let next = arena.next_free;

    if (let Some(p) <- prev) {
      p.next_free = next;
    } else {
      if (arena.size <= 40) {
        free_heads[arena.size] = next;
      } else {
        large_head = next;
      }
    }

    if (let Some(n) <- next) {
      n.prev_free = prev;
    }

    arena.prev_free = None;
    arena.next_free = None;
  }

  private func dig_trench(n: Int): Arena {
    let additional_size = n * 20;

    if (let Some(last) <- last_arena) {
      if (last.is_free) {
        remove_from_free(last);
        last.size += additional_size;
        add_to_free(last);
        return last;
      } else {
        let new_arena = Arena(last.end + 1, additional_size, true);
        last.right = Some(new_arena);
        new_arena.left = Some(last);
        last_arena = Some(new_arena);
        add_to_free(new_arena);
        return new_arena;
      }
    } else {
      let new_arena = Arena(0, additional_size, true);
      first_arena = Some(new_arena);
      last_arena = Some(new_arena);
      add_to_free(new_arena);
      return new_arena;
    }
  }

  public func allocate(size: Int): (Arena, Int) {
    var block: Option<Arena> = None;

    var i = size;
    while (i <= 40) {
      if (let Some(b) <- free_heads[i]) {
        block = Some(b);
        break;
      }
      i += 1;
    }

    if (block.isNone()) {
      if (let Some(b) <- large_head) {
        block = Some(b);
      }
    }

    var dug_trenches = 0;

    if (block.isNone()) {
      var tail_free_size = 0;
      if (let Some(last) <- last_arena) {
        if (last.is_free) {
          tail_free_size = last.size;
        }
      }
      let needed = size - tail_free_size;
      dug_trenches = (needed + 19) / 20;
      let new_free_block = dig_trench(dug_trenches);
      block = Some(new_free_block);
    }

    let unwrapped = block.getOrThrow();
    remove_from_free(unwrapped);

    let remainder = unwrapped.size - size;
    if (remainder > 0) {
      unwrapped.size = size;
      unwrapped.is_free = false;

      let free_rem = Arena(unwrapped.offset + size, remainder, true);
      free_rem.left = Some(unwrapped);
      free_rem.right = unwrapped.right;

      if (let Some(r) <- unwrapped.right) {
        r.left = Some(free_rem);
      } else {
        last_arena = Some(free_rem);
      }
      unwrapped.right = Some(free_rem);

      add_to_free(free_rem);
    } else {
      unwrapped.is_free = false;
    }

    return (unwrapped, dug_trenches);
  }

  public func free(arena: Arena): Unit {
    var start = arena.offset;
    var size = arena.size;
    var left_neighbor = arena.left;
    var right_neighbor = arena.right;

    if (let Some(l) <- left_neighbor) {
      if (l.is_free) {
        remove_from_free(l);
        start = l.offset;
        size += l.size;
        left_neighbor = l.left;
      }
    }
    if (let Some(r) <- right_neighbor) {
      if (r.is_free) {
        remove_from_free(r);
        size += r.size;
        right_neighbor = r.right;
        }
    }

    arena.offset = start;
    arena.size = size;
    arena.left = left_neighbor;
    arena.right = right_neighbor;

    if (let Some(l) <- left_neighbor) {
      l.right = Some(arena);
    } else {
      first_arena = Some(arena);
    }

    if (let Some(r) <- right_neighbor) {
      r.left = Some(arena);
    } else {
      last_arena = Some(arena);
    }

    add_to_free(arena);
  }
}