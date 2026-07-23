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
    // Prvi ulazak u aplikaciju: samo izbor jezika (jednom, nikad vise).
    if (!Prefs.langChosen) return _languagePicker();

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
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('subtitle'),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black54)),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${tr('playAs')}: ',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 28),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kInk,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _startGame(false),
                    child: Text(tr('twoPlayers'),
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kXColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _startGame(true),
                    child: Text(tr('vsPhone'),
                        style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _languagePicker() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('HEKS',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Choose your language / Izaberi jezik / Zgjidh gjuhën',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54)),
                const SizedBox(height: 28),
                for (final l in const [
                  ('en', 'English'),
                  ('sr', 'Srpski'),
                  ('sq', 'Shqip')
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: kInk,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => setState(() {
                        Prefs.lang = l.$1;
                        Prefs.langChosen = true;
                      }),
                      child: Text(l.$2, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
