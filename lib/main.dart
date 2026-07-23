import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prefs.dart';
import 'ui/menu_screen.dart';

Future<void> applyOrientation() async {
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
  await applyOrientation(); // landscape pri prvom pokretanju, pamti izbor
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
          home: const MenuScreen(),
        );
      },
    );
  }
}
