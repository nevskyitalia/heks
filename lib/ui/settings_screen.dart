import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../main.dart' show applyOrientation;
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
            Text(tr('language'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: Text(tr('lang_sr')),
              value: 'sr',
              groupValue: Prefs.lang,
              onChanged: (v) => setState(() => Prefs.lang = v!),
            ),
            RadioListTile<String>(
              title: Text(tr('lang_en')),
              value: 'en',
              groupValue: Prefs.lang,
              onChanged: (v) => setState(() => Prefs.lang = v!),
            ),
            RadioListTile<String>(
              title: Text(tr('lang_sq')),
              value: 'sq',
              groupValue: Prefs.lang,
              onChanged: (v) => setState(() => Prefs.lang = v!),
            ),
            const Divider(height: 32),
            Text(tr('orientation'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            RadioListTile<bool>(
              title: Text(tr('landscape')),
              value: false,
              groupValue: Prefs.portrait,
              onChanged: (v) async {
                setState(() => Prefs.portrait = false);
                await applyOrientation();
              },
            ),
            RadioListTile<bool>(
              title: Text(tr('portrait')),
              value: true,
              groupValue: Prefs.portrait,
              onChanged: (v) async {
                setState(() => Prefs.portrait = true);
                await applyOrientation();
              },
            ),
          ],
        ),
      ),
    );
  }
}
