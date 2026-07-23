import 'dart:math';
import 'engine.dart';

/// Telefon-igrac sa 10 nivoa jacine.
/// 1: potpuno nasumican
/// 2-4: sve cesce vidi pobedu/blokadu (30% / 60% / 90%)
/// 5: uvek uzme pobedu i blokira, inace nasumican
/// 6: + osecaj za jaca polja
/// 7: + dvostruke pretnje (pravi ih i blokira, umereno)
/// 8-10: gleda unapred (alfa-beta pretraga dubine 2/3/4) sa malom
///       stopom greske (12% / 6% / 3%) — nivo 10 je jak ali POBEDIV.
class Ai {
  final int level;
  final Random rng;
  Ai(this.level, [Random? r])
      : assert(level >= 1 && level <= 10),
        rng = r ?? Random();

  int choose(Game g) {
    final free = g.freeCells();
    if (free.length == 1) return free.first;
    final me = g.current, opp = 3 - me;

    if (level == 1) return free[rng.nextInt(free.length)];

    final double see = switch (level) {
      2 => 0.30,
      3 => 0.60,
      4 => 0.90,
      _ => 1.0,
    };
    final wins = _completing(g, free, me);
    if (wins.isNotEmpty && rng.nextDouble() < see) {
      return wins[rng.nextInt(wins.length)];
    }
    final blocks = _completing(g, free, opp);
    if (blocks.isNotEmpty && rng.nextDouble() < see) {
      return blocks[rng.nextInt(blocks.length)];
    }
    if (level <= 5) return free[rng.nextInt(free.length)];

    if (level <= 7) {
      if (level == 7) {
        final dt = _doubleThreats(g, free, me);
        if (dt.isNotEmpty && rng.nextDouble() < 0.7) {
          return dt[rng.nextInt(dt.length)];
        }
        final odt = _doubleThreats(g, free, opp);
        if (odt.isNotEmpty && rng.nextDouble() < 0.7) {
          return odt[rng.nextInt(odt.length)];
        }
      }
      return _weightedPick(g, free, me);
    }

    // nivoi 8-10 (parametri validirani turnirskom simulacijom)
    final blunder = switch (level) { 8 => 0.12, 9 => 0.10, _ => 0.02 };
    if (rng.nextDouble() < blunder) return _weightedPick(g, free, me);
    final depth = switch (level) { 8 => 2, _ => 3 };
    _kCandidates = switch (level) { 8 => 10, 9 => 8, _ => 12 };
    return _searchBest(g, depth, me);
  }

  /// Polja koja odmah kompletiraju liniju igraca [pl].
  List<int> _completing(Game g, List<int> free, int pl) {
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

  /// Potezi koji stvaraju >=2 neposredne pretnje za [pl].
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

  // ---------- alfa-beta pretraga (nivoi 8-10) ----------

  int _kCandidates = 10;

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
      if (other == 0 && mine > 0) score += mine == 1 ? 1 : (mine == 2 ? 12 : 0);
      if (mine == 0 && other > 0) {
        score -= other == 1 ? 1.1 : (other == 2 ? 14 : 0);
      }
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
    if (cands.isEmpty) return 0; // nereseno
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
