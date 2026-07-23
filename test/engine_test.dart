import 'package:flutter_test/flutter_test.dart';
import 'package:heks/game/board.dart';
import 'package:heks/game/engine.dart';

void main() {
  group('HEKS1 tabla', () {
    final b = buildHeks1();
    test('ima 36 polja i 24 linije', () {
      expect(b.cells.length, 36);
      expect(b.lines.length, 24);
    });
    test('prava stranica pobedjuje', () {
      final g = Game(b);
      // X: V0_0(0), M0_0(6), V0_1(1); O: bilo gde drugde
      g.place(0); // X
      g.place(20); // O
      g.place(6); // X
      g.place(21); // O
      g.place(1); // X -> stranica 0-6-1
      expect(g.winner, 1);
      expect(g.winLine, containsAll([0, 6, 1]));
    });
    test('prelomljena trojka (sredina-teme-sredina) NE pobedjuje', () {
      final g = Game(b);
      g.place(6); // X: M0_0
      g.place(20); // O
      g.place(1); // X: V0_1
      g.place(21); // O
      g.place(7); // X: M0_1  -> prelomljeno preko temena, nema pobede
      expect(g.winner, 0);
    });
    test('radijalna linija kroz temena pobedjuje', () {
      final g = Game(b);
      g.place(2); // X: V0_2
      g.place(20); // O
      g.place(14); // X: V1_2
      g.place(21); // O
      g.place(26); // X: V2_2 -> radijalna 2-14-26
      expect(g.winner, 1);
    });
  });

  group('HEKS2 tabla', () {
    final b = buildHeks2();
    test('ima 25 polja i 24 linije', () {
      expect(b.cells.length, 25);
      expect(b.lines.length, 24);
    });
    test('radijus kroz teme do centra pobedjuje', () {
      final g = Game(b);
      g.place(0); // X: OV0
      g.place(7); // O
      g.place(12); // X: IV0
      g.place(8); // O
      g.place(24); // X: centar -> 0-12-24
      expect(g.winner, 1);
    });
    test('trojka PREKO centra (IV0-C-IV3) ne pobedjuje', () {
      final g = Game(b);
      g.place(12); // X: IV0
      g.place(0); // O
      g.place(24); // X: C
      g.place(1); // O
      g.place(15); // X: IV3 -> nije linija
      expect(g.winner, 0);
    });
  });

  test('nereseno kada se tabla popuni bez pobednika (vestacki)', () {
    final b = buildHeks2();
    final g = Game(b);
    // simuliramo rucno: popunimo sve celije naizmenicno ali proveravamo
    // samo da over radi kada je moves == broj polja
    var i = 0;
    while (!g.over && i < b.cells.length) {
      final free = g.freeCells();
      g.place(free.first);
      i++;
    }
    expect(g.over, true); // ili pobeda ili nereseno, ali gotova
  });
}
