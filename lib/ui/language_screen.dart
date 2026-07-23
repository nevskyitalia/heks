import 'package:flutter/material.dart';
import '../prefs.dart';
import 'play_screen.dart';
import 'settings_screen.dart';

/// Izbor jezika pri pokretanju.
/// NAPOMENA ZA TESTIRANJE: trenutno se prikazuje PRI SVAKOM pokretanju.
/// Kada testiranje zavrsi, u main.dart preskociti ovaj ekran ako je
/// Prefs.langChosen == true (vec pripremljeno, samo odkomentarisati).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _pick(BuildContext context, String lang) {
    Prefs.lang = lang;
    Prefs.langChosen = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PlayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('HEKS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Choose your language / Izaberi jezik / Zgjidh gjuhën',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black54)),
                    const SizedBox(height: 28),
                    for (final l in const [
                      ('en', 'English'),
                      ('sr', 'Srpski'),
                      ('sq', 'Shqip')
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 24),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _pick(context, l.$1),
                          child:
                              Text(l.$2, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.settings, size: 28),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
