import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:heks/game/ai.dart';
import 'package:heks/game/board.dart';
import 'package:heks/game/engine.dart';

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
  test('svaki nivo daje legalan potez do kraja partije', () {
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

  test('nivo 10 uvek uzima pobednicki potez', () {
    final g = Game(buildHeks1());
    g.place(0); // X
    g.place(20); // O
    g.place(6); // X
    g.place(21); // O -> X na potezu, pobeda na polju 1
    final ai = Ai(10, Random(1));
    for (var t = 0; t < 20; t++) {
      expect(ai.choose(g), 1);
    }
  });

  test('nivo 10 uvek blokira neposrednu pretnju', () {
    final g = Game(buildHeks1());
    g.place(0); // X
    g.place(20); // O
    g.place(6); // X preti na polju 1; O mora blok
    final ai = Ai(10, Random(2));
    for (var t = 0; t < 20; t++) {
      expect(ai.choose(g), 1);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('jacina raste sa nivoom (grubo)', () {
    expect(match(4, 1, 60, 11), greaterThan(55));
    expect(match(8, 4, 60, 12), greaterThan(55));
    expect(match(10, 8, 40, 13), greaterThan(55));
  }, timeout: const Timeout(Duration(minutes: 10)));

  test('vrh lestvice: nivo 9 osvaja deo poena protiv nivoa 10', () {
    final s = match(9, 10, 60, 14);
    expect(s, greaterThan(5)); // pobediv za jako pametnog igraca
    expect(s, lessThan(45)); // ali i dalje jasno slabiji
  }, timeout: const Timeout(Duration(minutes: 10)));
}
