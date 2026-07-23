import 'dart:math';
import 'package:flutter/material.dart';
import '../game/board.dart';
import '../game/engine.dart';

const Color kInk = Color(0xFF111111);
const Color kXColor = Color(0xFFC0392B);
const Color kOColor = Color(0xFF2266CC);
const Color kWinColor = Color(0xFF1E9E50);
const Color kWinFill = Color(0xFFE2F7E9);

/// Iscrtava mrezu i prima dodire na celije.
/// Ako se oblik table ne uklapa u orijentaciju ekrana, tabla se
/// automatski rotira za 90 stepeni da maksimalno popuni ekran.
class BoardWidget extends StatelessWidget {
  final Game game;
  final void Function(int cell) onTap;
  const BoardWidget({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final geom = _Geometry(game.board, size);
      return GestureDetector(
        onTapUp: (d) {
          final cell = geom.hitTest(d.localPosition);
          if (cell != null) onTap(cell);
        },
        child: CustomPaint(
          size: size,
          painter: _BoardPainter(game, geom),
        ),
      );
    });
  }
}

class _Geometry {
  final BoardDef board;
  final Size size;
  late final bool rotated;
  late final double scale;
  late final Offset offset;

  _Geometry(this.board, this.size) {
    final wideBoard = board.width >= board.height;
    final wideScreen = size.width >= size.height;
    rotated = wideBoard != wideScreen;
    final bw = rotated ? board.height : board.width;
    final bh = rotated ? board.width : board.height;
    scale = min(size.width / bw, size.height / bh);
    offset = Offset(size.width / 2, size.height / 2);
  }

  Offset map(Point<double> p) {
    final cx = (board.minX + board.maxX) / 2;
    final cy = (board.minY + board.maxY) / 2;
    var x = p.x - cx, y = p.y - cy;
    if (rotated) {
      final t = x;
      x = -y;
      y = t;
    }
    return Offset(offset.dx + x * scale, offset.dy + y * scale);
  }

  double get cellRadius => board.cellR * scale;

  int? hitTest(Offset pos) {
    int? best;
    double bestD = cellRadius * 1.7;
    for (var i = 0; i < board.cells.length; i++) {
      final c = map(board.cells[i]);
      final d = (c - pos).distance;
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }
}

class _BoardPainter extends CustomPainter {
  final Game game;
  final _Geometry geom;
  _BoardPainter(this.game, this.geom);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = kInk
      ..strokeWidth = max(1.5, geom.cellRadius * 0.16)
      ..style = PaintingStyle.stroke;

    // linije: svaka pobednicka linija kao segment od prve do poslednje celije
    for (final line in game.board.lines) {
      final a = geom.map(game.board.cells[line.first]);
      final b = geom.map(game.board.cells[line.last]);
      canvas.drawLine(a, b, linePaint);
    }

    final r = geom.cellRadius;
    for (var i = 0; i < game.board.cells.length; i++) {
      final c = geom.map(game.board.cells[i]);
      final isWin = game.winLine?.contains(i) ?? false;
      final fill = Paint()
        ..color = isWin ? kWinFill : Colors.white
        ..style = PaintingStyle.fill;
      final ring = Paint()
        ..color = isWin ? kWinColor : kInk
        ..strokeWidth = isWin ? r * 0.28 : r * 0.14
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, ring);
      final o = game.owner[i];
      if (o != 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: o == 1 ? 'X' : 'O',
            style: TextStyle(
              color: o == 1 ? kXColor : kOColor,
              fontSize: r * 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}
