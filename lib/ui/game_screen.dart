import 'dart:math';
import 'package:flutter/material.dart';
import '../game/ai.dart';
import '../game/board.dart';
import '../game/engine.dart';
import '../l10n/strings.dart';
import 'board_widget.dart';

class GameScreen extends StatefulWidget {
  final BoardDef board;
  final bool vsPhone;
  final int aiLevel;
  final int humanSide; // 1 = X, 2 = O (samo za vsPhone)
  const GameScreen({
    super.key,
    required this.board,
    required this.vsPhone,
    this.aiLevel = 3,
    this.humanSide = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game game;
  late Ai ai;
  bool thinking = false;

  @override
  void initState() {
    super.initState();
    game = Game(widget.board);
    ai = Ai(widget.aiLevel, Random());
    _maybePhoneMove();
  }

  bool get phoneTurn =>
      widget.vsPhone && !game.over && game.current != widget.humanSide;

  Future<void> _maybePhoneMove() async {
    if (!phoneTurn) return;
    setState(() => thinking = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final mv = ai.choose(game);
    setState(() {
      game.place(mv);
      thinking = false;
    });
    // (ako bi telefon igrao sam sa sobom, ovde bi isao rekurzivni poziv)
  }

  void _onTap(int cell) {
    if (game.over || thinking) return;
    if (widget.vsPhone && game.current != widget.humanSide) return;
    final ok = game.place(cell);
    if (!ok) return;
    setState(() {});
    _maybePhoneMove();
  }

  void _newGame() {
    setState(() {
      game.reset();
      thinking = false;
    });
    _maybePhoneMove();
  }

  String _statusText() {
    if (game.winner != 0) {
      if (widget.vsPhone) {
        return game.winner == widget.humanSide ? tr('youWin') : tr('phoneWins');
      }
      return game.winner == 1 ? tr('xWins') : tr('oWins');
    }
    if (game.isDraw) return tr('draw');
    if (thinking) return tr('thinking');
    final mark = game.current == 1 ? 'X' : 'O';
    if (widget.vsPhone) {
      final who =
          game.current == widget.humanSide ? tr('you') : tr('phone');
      return '${tr('turn')}: $who ($mark)';
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                _statusText(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: BoardWidget(game: game, onTap: _onTap),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: kInk),
                    onPressed: _newGame,
                    child: Text(tr('newGame')),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('back')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
