import std.convert.Parsable;
import std.console.*;

enum Command {
  | Extract | Insert
}

main() {
  var pipesCollection = PipesCollection();
  Console.stdOut.flush();
  while (true) {
    let command = Int.parse(Console.stdIn.readln().getOrThrow());
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
    Console.stdOut.flush();
  }
  Console.stdOut.flush();
}