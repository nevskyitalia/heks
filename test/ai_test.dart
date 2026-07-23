import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:heks/game/ai.dart';
import 'package:heks/game/board.dart';
import 'package:heks/game/engine.dart';

/// Odigraj [n] partija: levelA igra kao X u polovini, kao O u polovini.
/// Vraca procenat poena za A (pobeda 1, nereseno 0.5).
double match(int levelA, int levelB, int n, int seed) {
  final rng = Random(seed);
  var scoreA = 0.0;
  final board = buildHeks1();
  for (var g = 0; g < n; g++) {
    final aIsX = g % 2 == 0;
    final ai1 = Ai(aIsX ? levelA : levelB, Random(rng.nextInt(1 << 30)));
    final ai2 = Ai(aIsX ? levelB : levelA, Random(rng.nextInt(1 << 30)));
    final game = Game(board);
    while (!game.over) {
      final ai = game.current == 1 ? ai1 : ai2;
      game.place(ai.choose(game));
    }
    if (game.winner == 0) {
      scoreA += 0.5;
    } else {
      final aWon = (game.winner == 1) == aIsX;
      if (aWon) scoreA += 1;
    }
  }
  return scoreA / n * 100;
}

void main() {
  test('svaki nivo daje legalan potez', () {
    for (var level = 1; level <= 10; level++) {
      final g = Game(buildHeks1());
      final ai = Ai(level, Random(7));
      while (!g.over) {
        final mv = ai.choose(g);
        expect(g.owner[mv], 0);
        g.place(mv);
      }
      expect(g.over, true);
    }
  });

  test('nivo 5 uvek uzima pobednicki potez', () {
    final g = Game(buildHeks1());
    // X (AI) postavi 0 i 6; treba da odigra 1 za pobedu
    g.place(0); // X
    g.place(20); // O
    g.place(6); // X
    g.place(21); // O -> X na potezu
    final ai = Ai(5, Random(1));
    for (var t = 0; t < 20; t++) {
      expect(ai.choose(g), 1); // jedini pobednicki potez
    }
  });

  test('nivo 5 uvek blokira neposrednu pretnju', () {
    final g = Game(buildHeks1());
    g.place(0); // X
    g.place(20); // O
    g.place(6); // X preti sa 0-6-1
    // O na potezu, mora blok na 1
    final ai = Ai(5, Random(2));
    for (var t = 0; t < 20; t++) {
      expect(ai.choose(g), 1);
    }
  });

  test('snaga raste: visi nivo dobija nizi (grubo)', () {
    // stedljivo: manji uzorci, samo kljucne provere monotonosti
    expect(match(4, 1, 60, 11), greaterThan(55));
    expect(match(7, 4, 60, 12), greaterThan(55));
    expect(match(10, 7, 40, 13), greaterThan(55));
  });

  test('nivo 10 nije nepobediv (gubi bar nekad od nivoa 7)', () {
    final s = match(7, 10, 40, 14);
    expect(s, greaterThan(0)); // nivo 7 osvoji bar nesto poena
  });
}
