import 'package:flutter/material.dart';
import '../game/board.dart';
import '../l10n/strings.dart';
import '../prefs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(tr('settings')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- mreza ---
            Text(tr('board'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            for (final b in allBoards)
              RadioListTile<String>(
                title: Text(tr('board_${b.id}')),
                value: b.id,
                groupValue: Prefs.boardId,
                onChanged: (v) => setState(() => Prefs.boardId = v!),
              ),
            const Divider(height: 28),
            // --- jacina bota ---
            Text('${tr('level')}: ${Prefs.aiLevel} (${Prefs.aiLevel * 10}%)',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Slider(
              value: Prefs.aiLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${Prefs.aiLevel}',
              onChanged: (v) => setState(() => Prefs.aiLevel = v.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 = ${tr('levelHint1')}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                Text('10 = ${tr('levelHint10')}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const Divider(height: 28),
            // --- jezik ---
            Text(tr('language'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            for (final l in const [
              ('en', 'lang_en'),
              ('sr', 'lang_sr'),
              ('sq', 'lang_sq')
            ])
              RadioListTile<String>(
                title: Text(tr(l.$2)),
                value: l.$1,
                groupValue: Prefs.lang,
                onChanged: (v) => setState(() => Prefs.lang = v!),
              ),
            const Divider(height: 28),
            // --- orijentacija igre ---
            Text(tr('orientation'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            RadioListTile<bool>(
              title: Text(tr('landscape')),
              value: false,
              groupValue: Prefs.portrait,
              onChanged: (v) => setState(() => Prefs.portrait = false),
            ),
            RadioListTile<bool>(
              title: Text(tr('portrait')),
              value: true,
              groupValue: Prefs.portrait,
              onChanged: (v) => setState(() => Prefs.portrait = true),
            ),
          ],
        ),
      ),
    );
  }
}
