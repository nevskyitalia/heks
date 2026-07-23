import 'dart:math';
import 'package:flutter/material.dart';
import '../game/ai.dart';
import '../game/board.dart';
import '../game/engine.dart';
import '../l10n/strings.dart';
import '../main.dart' show setGameOrientation;
import '../prefs.dart';
import 'board_widget.dart';
import 'settings_screen.dart';

enum PlayMode { lobby, twoPlayers, vsBot, botVsBot }

/// Glavni ekran: mreza je uvek prikazana; u lobby stanju preko nje stoji
/// prozor sa izborom X/O i moda. Settings sraf je UVEK u gornjem desnom uglu.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late Game game;
  PlayMode mode = PlayMode.lobby;
  Ai? bot; // protiv coveka
  Ai? botX, botO; // bot vs bot
  bool thinking = false;
  int humanSide = 1;
  int _session = 0; // prekida zaostale asinhrone poteze

  @override
  void initState() {
    super.initState();
    game = Game(boardById(Prefs.boardId));
    setGameOrientation();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (!mounted) return;
    await setGameOrientation();
    setState(() {
      // u lobby stanju odmah primeni eventualnu promenu mreze
      if (mode == PlayMode.lobby && game.board.id != Prefs.boardId) {
        game = Game(boardById(Prefs.boardId));
      }
    });
  }

  void _start(PlayMode m) {
    _session++;
    setState(() {
      mode = m;
      humanSide = Prefs.humanSide;
      game = Game(boardById(Prefs.boardId));
      bot = Ai(Prefs.aiLevel, Random());
      botX = Ai(Prefs.aiLevel, Random());
      botO = Ai(Prefs.aiLevel, Random());
      thinking = false;
    });
    if (m == PlayMode.vsBot) _maybeBotMove();
    if (m == PlayMode.botVsBot) _botLoop();
  }

  Future<void> _maybeBotMove() async {
    if (mode != PlayMode.vsBot || game.over || game.current == humanSide) {
      return;
    }
    final s = _session;
    setState(() => thinking = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted || s != _session) return;
    setState(() {
      game.place(bot!.choose(game));
      thinking = false;
    });
  }

  Future<void> _botLoop() async {
    final s = _session;
    while (mounted &&
        s == _session &&
        mode == PlayMode.botVsBot &&
        !game.over) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || s != _session || mode != PlayMode.botVsBot || game.over) {
        break;
      }
      final ai = game.current == 1 ? botX! : botO!;
      setState(() => game.place(ai.choose(game)));
    }
  }

  void _onTap(int cell) {
    if (mode == PlayMode.lobby || mode == PlayMode.botVsBot) return;
    if (game.over || thinking) return;
    if (mode == PlayMode.vsBot && game.current != humanSide) return;
    if (!game.place(cell)) return;
    setState(() {});
    if (mode == PlayMode.vsBot) _maybeBotMove();
  }

  void _newGame() => _start(mode);

  void _back() {
    _session++;
    setState(() {
      mode = PlayMode.lobby;
      game = Game(boardById(Prefs.boardId));
      thinking = false;
    });
  }

  String _status() {
    if (mode == PlayMode.lobby) return '';
    if (game.winner != 0) {
      if (mode == PlayMode.vsBot) {
        return game.winner == humanSide ? tr('youWin') : tr('phoneWins');
      }
      return game.winner == 1 ? tr('xWins') : tr('oWins');
    }
    if (game.isDraw) return tr('draw');
    if (thinking) return tr('thinking');
    final mark = game.current == 1 ? 'X' : 'O';
    if (mode == PlayMode.vsBot) {
      final who = game.current == humanSide ? tr('you') : tr('phone');
      return '${tr('turn')}: $who ($mark)';
    }
    if (mode == PlayMode.botVsBot) {
      return '${tr('turn')}: ${tr('phone')} ($mark)';
    }
    return '${tr('turn')}: $mark';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = game.winner != 0
        ? kWinColor
        : (game.current == 1 ? kXColor : kOColor);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(4, 40, 4, 4),
                    child: BoardWidget(game: game, onTap: _onTap),
                  ),
                ),
                if (mode != PlayMode.lobby)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _status(),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 18),
                        FilledButton(
                          style:
                              FilledButton.styleFrom(backgroundColor: kInk),
                          onPressed: _newGame,
                          child: Text(tr('newGame')),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _back,
                          child: Text(tr('back')),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (mode == PlayMode.lobby) _lobbyOverlay(),
            // Settings sraf: UVEK vidljiv, gornji desni ugao
            Positioned(
              top: 2,
              right: 2,
              child: Material(
                color: Colors.white.withOpacity(0.85),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.settings, size: 30),
                  tooltip: tr('settings'),
                  onPressed: _openSettings,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lobbyOverlay() {
    return Center(
      child: Card(
        elevation: 8,
        color: const Color(0xFFFFFDF8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr('appTitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${tr('playAs')}: ',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('X')),
                        ButtonSegment(value: 2, label: Text('O')),
                      ],
                      selected: {Prefs.humanSide},
                      onSelectionChanged: (s) =>
                          setState(() => Prefs.humanSide = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kInk,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _start(PlayMode.twoPlayers),
                  child:
                      Text(tr('twoPlayers'), style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kXColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _start(PlayMode.vsBot),
                  child:
                      Text(tr('vsPhone'), style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kOColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _start(PlayMode.botVsBot),
                  child:
                      Text(tr('botVsBot'), style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
