import std.env.*
import std.convert.Parsable;

enum Command {
  | Extract | Insert
}

main() {
  var pipesCollection = PipesCollection()
  getStdOut().flush()
  while (true) {
    let command = Int.parse(getStdIn().readln().getOrThrow())
    let answer = match {
      case command < 0 => (pipesCollection.extract(-command), Command.Extract) // -command is Pipe ID
      case command > 0 => (pipesCollection.insert(command), Command.Insert) // command is Length of Pipe
      case _ => break
    }

    match (answer) {
      case ((_, offset), Command.Extract) => println("${offset}")
      case ((D, N), Command.Insert) => println("${N} ${D}")
      case (_, _) => break
    }
    getStdOut().flush()
  }
  getStdOut().flush()
}
