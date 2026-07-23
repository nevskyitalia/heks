import 'dart:math';

/// Definicija jedne mreze (table).
/// Nove mreze se dodaju tako sto se napise jos jedna build funkcija
/// i doda u [allBoards] — nista drugo u aplikaciji ne treba menjati.
class BoardDef {
  final String id;
  final List<Point<double>> cells; // normalizovane koordinate
  final List<List<int>> lines; // pobednicke linije (indeksi celija)
  final double cellR; // poluprecnik celije u normalizovanim jedinicama

  const BoardDef({
    required this.id,
    required this.cells,
    required this.lines,
    required this.cellR,
  });

  double get minX => cells.map((c) => c.x).reduce(min) - cellR * 1.6;
  double get maxX => cells.map((c) => c.x).reduce(max) + cellR * 1.6;
  double get minY => cells.map((c) => c.y).reduce(min) - cellR * 1.6;
  double get maxY => cells.map((c) => c.y).reduce(max) + cellR * 1.6;
  double get width => maxX - minX;
  double get height => maxY - minY;
}

const double _deg = pi / 180.0;
final double _ap = cos(30 * _deg); // apotema faktor

/// HEKS1: tri sestougla (1 : 0.7 : 0.4), izduzena 1.56 x 0.84,
/// 36 polja (temena + sredine stranica), 24 linije:
/// 18 stranica (teme-sredina-teme) + 6 radijalnih kroz temena.
BoardDef buildHeks1() {
  const sx = 1.56, sy = 0.84;
  const scales = [1.0, 0.7, 0.4];
  final cells = <Point<double>>[];
  // raspored: za h u 0..2 -> 6 temena (V), pa 6 sredina (M)
  for (var h = 0; h < 3; h++) {
    final s = scales[h];
    for (var k = 0; k < 6; k++) {
      final a = 60.0 * k * _deg;
      cells.add(Point(s * cos(a) * sx, s * sin(a) * sy));
    }
    for (var k = 0; k < 6; k++) {
      final a = (60.0 * k + 30.0) * _deg;
      cells.add(Point(s * _ap * cos(a) * sx, s * _ap * sin(a) * sy));
    }
  }
  int v(int h, int k) => h * 12 + (k % 6);
  int m(int h, int k) => h * 12 + 6 + (k % 6);
  final lines = <List<int>>[];
  for (var h = 0; h < 3; h++) {
    for (var k = 0; k < 6; k++) {
      lines.add([v(h, k), m(h, k), v(h, k + 1)]); // stranica
    }
  }
  for (var k = 0; k < 6; k++) {
    lines.add([v(0, k), v(1, k), v(2, k)]); // radijalna kroz temena
  }
  return BoardDef(id: 'heks1', cells: cells, lines: lines, cellR: 0.0715);
}

/// HEKS2: dva sestougla (1 : 0.6) + centar, 25 polja, 24 linije:
/// 12 stranica + 6 radijusa kroz temena + 6 radijusa kroz sredine
/// (svi radijusi idu do centra).
BoardDef buildHeks2() {
  const sx = 1.2; // 20% sira => krupnija na ekranu
  const scales = [1.0, 0.6];
  final cells = <Point<double>>[];
  for (var h = 0; h < 2; h++) {
    final s = scales[h];
    for (var k = 0; k < 6; k++) {
      final a = 60.0 * k * _deg;
      cells.add(Point(s * cos(a) * sx, s * sin(a)));
    }
    for (var k = 0; k < 6; k++) {
      final a = (60.0 * k + 30.0) * _deg;
      cells.add(Point(s * _ap * cos(a) * sx, s * _ap * sin(a)));
    }
  }
  final center = cells.length;
  cells.add(const Point(0.0, 0.0));
  int v(int h, int k) => h * 12 + (k % 6);
  int m(int h, int k) => h * 12 + 6 + (k % 6);
  final lines = <List<int>>[];
  for (var h = 0; h < 2; h++) {
    for (var k = 0; k < 6; k++) {
      lines.add([v(h, k), m(h, k), v(h, k + 1)]);
    }
  }
  for (var k = 0; k < 6; k++) {
    lines.add([v(0, k), v(1, k), center]); // radijus kroz temena
    lines.add([m(0, k), m(1, k), center]); // radijus kroz sredine
  }
  return BoardDef(id: 'heks2', cells: cells, lines: lines, cellR: 0.117);
}

final List<BoardDef> allBoards = [buildHeks1(), buildHeks2()];

BoardDef boardById(String id) =>
    allBoards.firstWhere((b) => b.id == id, orElse: () => allBoards.first);
