import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Trajna podesavanja (pamte se i posle gasenja aplikacije).
class Prefs {
  static late SharedPreferences _p;
  static final ValueNotifier<int> rev = ValueNotifier(0);

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static void _bump() => rev.value++;

  static String get lang => _p.getString('lang') ?? 'en';
  static set lang(String v) {
    _p.setString('lang', v);
    _bump();
  }

  /// Da li je korisnik vec prosao prvi izbor jezika (pojavljuje se jednom).
  static bool get langChosen => _p.getBool('langChosen') ?? false;
  static set langChosen(bool v) {
    _p.setBool('langChosen', v);
    _bump();
  }

  /// false = landscape (default za IGRU), true = portrait za igru.
  /// Meniji i podesavanja su uvek portrait.
  static bool get portrait => _p.getBool('portrait') ?? false;
  static set portrait(bool v) {
    _p.setBool('portrait', v);
    _bump();
  }

  static String get boardId => _p.getString('board') ?? 'heks1';
  static set boardId(String v) {
    _p.setString('board', v);
    _bump();
  }

  static int get aiLevel => _p.getInt('aiLevel') ?? 4;
  static set aiLevel(int v) {
    _p.setInt('aiLevel', v);
    _bump();
  }

  static int get humanSide => _p.getInt('humanSide') ?? 1; // 1 = X, 2 = O
  static set humanSide(int v) {
    _p.setInt('humanSide', v);
    _bump();
  }
}
