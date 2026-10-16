import std.convert.*;

enum Command {
  | Extract | Insert
}

main() {
  var pipesCollection = PipesCollection();
  while (true) {
    let command = Int.parse(readln());
    let answer = match {
      case command < 0 => (pipesCollection.extract(-command), Command.Extract); // -command is Pipe ID
      case command > 0 => (pipesCollection.insert(command), Command.Insert); // command is Length of Pipe
      case _ => break;
    }

    match (answer) {
      case ((pipeId, offset), Command.Extract) => println("${offset}")
      case ((D, N), Command.Insert) => println("${N} ${D}");
      case (_, _) => break;
    }
  }

  println("Program finished");
}