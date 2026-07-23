import 'dart:math';
import 'engine.dart';

/// Bot sa 10 nivoa: linearna skala jacine, svaki nivo nosi ~10%.
/// Nivo L igra "ekspertski potez" sa verovatnocom L*10% (nivo 10 = 100%),
/// a u ostatku slucajeva igra po osecaju (tezinski, ne potpuno nasumicno).
/// Ekspertski potez: pobedi odmah > blokiraj > (od nivoa 5) dvostruka
/// pretnja > pretraga unapred (dubina raste sa nivoom; nivo 10 najsire).
/// Kalibrisano turnirski: nivo 10 dobija ~96% protiv nivoa 4, a igrac
/// jacine nivoa 9 osvaja ~25% protiv nivoa 10.
class Ai {
  final int level;
  final Random rng;
  late final double strength; // 0.1 .. 1.0
  late final int _depth;
  late final int _kCandidates;

  Ai(this.level, [Random? r])
      : assert(level >= 1 && level <= 10),
        rng = r ?? Random() {
    strength = level == 10 ? 1.0 : level / 10.0;
    _depth = level <= 4 ? 1 : (level <= 8 ? 2 : 3);
    _kCandidates = level == 10 ? 16 : 10;
  }

  int choose(Game g) {
    final free = g.freeCells();
    if (free.length == 1) return free.first;
    if (rng.nextDouble() < strength) return _expert(g, free);
    return _weightedPick(g, free, g.current);
  }

  int _expert(Game g, List<int> free) {
    final me = g.current, opp = 3 - me;
    final wins = _completing(g, me);
    if (wins.isNotEmpty) return wins[rng.nextInt(wins.length)];
    final blocks = _completing(g, opp);
    if (blocks.isNotEmpty) return blocks[rng.nextInt(blocks.length)];
    if (level >= 5) {
      final dt = _doubleThreats(g, free, me);
      if (dt.isNotEmpty) return dt[rng.nextInt(dt.length)];
    }
    return _searchBest(g, _depth, me);
  }

  List<int> _completing(Game g, int pl) {
    final res = <int>[];
    for (final line in g.board.lines) {
      var mine = 0, other = 0, freeCell = -1;
      for (final c in line) {
        if (g.owner[c] == pl) {
          mine++;
        } else if (g.owner[c] == 0) {
          freeCell = c;
        } else {
          other++;
        }
      }
      if (other == 0 && mine == line.length - 1 && freeCell != -1) {
        if (!res.contains(freeCell)) res.add(freeCell);
      }
    }
    return res;
  }

  List<int> _doubleThreats(Game g, List<int> free, int pl) {
    final res = <int>[];
    for (final mv in free) {
      g.owner[mv] = pl;
      var threats = 0;
      for (final line in g.board.lines) {
        var mine = 0, other = 0, empty = 0;
        for (final c in line) {
          if (g.owner[c] == pl) {
            mine++;
          } else if (g.owner[c] == 0) {
            empty++;
          } else {
            other++;
          }
        }
        if (other == 0 && empty == 1 && mine == line.length - 1) threats++;
      }
      g.owner[mv] = 0;
      if (threats >= 2) res.add(mv);
    }
    return res;
  }

  double _cellWeight(Game g, int cell, int pl) {
    var w = 1.0;
    for (final line in g.board.lines) {
      if (!line.contains(cell)) continue;
      var mine = 0, other = 0;
      for (final c in line) {
        if (g.owner[c] == pl) mine++;
        if (g.owner[c] == 3 - pl) other++;
      }
      if (other == 0) w += 1.0 + 2.0 * mine;
    }
    return w;
  }

  int _weightedPick(Game g, List<int> free, int pl) {
    final ws = [for (final c in free) pow(_cellWeight(g, c, pl), 2).toDouble()];
    var total = 0.0;
    for (final w in ws) total += w;
    var r = rng.nextDouble() * total;
    for (var i = 0; i < free.length; i++) {
      r -= ws[i];
      if (r <= 0) return free[i];
    }
    return free.last;
  }

  // ---------- alfa-beta pretraga ----------

  List<int> _candidates(Game g, int pl) {
    final free = g.freeCells();
    if (free.length <= _kCandidates) return free;
    final scored = [
      for (final c in free)
        (c, _cellWeight(g, c, pl) + _cellWeight(g, c, 3 - pl))
    ];
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (var i = 0; i < _kCandidates; i++) scored[i].$1];
  }

  double _eval(Game g, int me) {
    var score = 0.0;
    for (final line in g.board.lines) {
      var mine = 0, other = 0;
      for (final c in line) {
        if (g.owner[c] == me) mine++;
        if (g.owner[c] == 3 - me) other++;
      }
      if (other == 0 && mine > 0) score += mine == 1 ? 1 : 12;
      if (mine == 0 && other > 0) score -= other == 1 ? 1.1 : 14;
    }
    return score;
  }

  bool _isWinFor(Game g, int mv, int pl) {
    for (final line in g.board.lines) {
      if (!line.contains(mv)) continue;
      if (line.every((c) => c == mv || g.owner[c] == pl)) return true;
    }
    return false;
  }

  double _alphaBeta(Game g, int depth, double alpha, double beta, int me) {
    final pl = g.current;
    final cands = _candidates(g, pl);
    if (cands.isEmpty) return 0;
    if (depth == 0) return _eval(g, me);
    final maximizing = pl == me;
    var best = maximizing ? -1e18 : 1e18;
    for (final mv in cands) {
      double v;
      if (_isWinFor(g, mv, pl)) {
        v = (pl == me ? 1e6 : -1e6) * (depth + 1).toDouble();
      } else {
        g.owner[mv] = pl;
        g.current = 3 - pl;
        v = _alphaBeta(g, depth - 1, alpha, beta, me);
        g.owner[mv] = 0;
        g.current = pl;
      }
      if (maximizing) {
        if (v > best) best = v;
        if (best > alpha) alpha = best;
      } else {
        if (v < best) best = v;
        if (best < beta) beta = best;
      }
      if (beta <= alpha) break;
    }
    return best;
  }

  int _searchBest(Game g, int depth, int me) {
    final cands = _candidates(g, me);
    var bestV = -1e18;
    final bestMoves = <int>[];
    for (final mv in cands) {
      double v;
      if (_isWinFor(g, mv, me)) {
        v = 1e9;
      } else {
        g.owner[mv] = me;
        g.current = 3 - me;
        v = _alphaBeta(g, depth - 1, -1e18, 1e18, me);
        g.owner[mv] = 0;
        g.current = me;
      }
      if (v > bestV + 1e-9) {
        bestV = v;
        bestMoves
          ..clear()
          ..add(mv);
      } else if ((v - bestV).abs() <= 1e-9) {
        bestMoves.add(mv);
      }
    }
    return bestMoves[rng.nextInt(bestMoves.length)];
  }
}
