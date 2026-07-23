import 'board.dart';

/// Stanje jedne partije. Igraci su 1 (X) i 2 (O).
class Game {
  final BoardDef board;
  late List<int> owner; // 0 prazno, 1 X, 2 O
  int current = 1;
  int winner = 0; // 0 = nema jos, 1/2 = pobednik
  List<int>? winLine;
  int moves = 0;

  Game(this.board) {
    reset();
  }

  void reset() {
    owner = List.filled(board.cells.length, 0);
    current = 1;
    winner = 0;
    winLine = null;
    moves = 0;
  }

  bool get isDraw => winner == 0 && moves == board.cells.length;
  bool get over => winner != 0 || isDraw;

  /// Odigraj potez na polju [i]. Vraca true ako je potez legalan.
  bool place(int i) {
    if (over || i < 0 || i >= owner.length || owner[i] != 0) return false;
    owner[i] = current;
    moves++;
    for (final line in board.lines) {
      if (line.contains(i) && line.every((c) => owner[c] == current)) {
        winner = current;
        winLine = line;
        return true;
      }
    }
    if (!isDraw) current = 3 - current;
    return true;
  }

  List<int> freeCells() =>
      [for (var i = 0; i < owner.length; i++) if (owner[i] == 0) i];
}
