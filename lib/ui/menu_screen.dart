import 'package:flutter/material.dart';
import '../game/board.dart';
import '../l10n/strings.dart';
import '../prefs.dart';
import 'board_widget.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  void _startGame(bool vsPhone) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameScreen(
        board: boardById(Prefs.boardId),
        vsPhone: vsPhone,
        aiLevel: Prefs.aiLevel,
        humanSide: Prefs.humanSide,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(tr('appTitle'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: tr('settings'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.black54)),
                  const SizedBox(height: 18),
                  // izbor mreze
                  Row(
                    children: [
                      Text('${tr('board')}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: [
                            for (final b in allBoards)
                              ButtonSegment(
                                  value: b.id, label: Text(tr('board_${b.id}'))),
                          ],
                          selected: {Prefs.boardId},
                          onSelectionChanged: (s) =>
                              setState(() => Prefs.boardId = s.first),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kInk,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _startGame(false),
                    child: Text(tr('twoPlayers'),
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // izbor znaka
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${tr('playAs')}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
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
                        const SizedBox(height: 8),
                        // nivo 1-10
                        Row(
                          children: [
                            Text('${tr('level')}: ${Prefs.aiLevel}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: Prefs.aiLevel.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '${Prefs.aiLevel}',
                          onChanged: (v) =>
                              setState(() => Prefs.aiLevel = v.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 = ${tr('levelHint1')}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            Text('10 = ${tr('levelHint10')}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kXColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _startGame(true),
                          child: Text(tr('vsPhone'),
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
