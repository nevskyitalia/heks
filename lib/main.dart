import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prefs.dart';
import 'ui/language_screen.dart';

/// Meniji i podesavanja su uvek uspravno (portrait).
Future<void> setMenuOrientation() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Ekran igre: polozeno po defaultu, ili uspravno ako je korisnik
/// tako izabrao u podesavanjima (izbor se trajno pamti).
Future<void> setGameOrientation() async {
  if (Prefs.portrait) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await setMenuOrientation();
  runApp(const HeksApp());
}

class HeksApp extends StatelessWidget {
  const HeksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Prefs.rev,
      builder: (context, _, __) {
        return MaterialApp(
          title: 'HEKS',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF111111),
              surface: const Color(0xFFF7F5F0),
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F5F0),
            fontFamily: 'serif',
          ),
          // ZA TESTIRANJE: jezik se bira pri svakom pokretanju.
          // Kasnije: home = Prefs.langChosen ? const PlayScreen() : const LanguageScreen()
          home: const LanguageScreen(),
        );
      },
    );
  }
}
