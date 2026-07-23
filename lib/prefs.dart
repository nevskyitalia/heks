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

  static String get lang => _p.getString('lang') ?? 'sr';
  static set lang(String v) {
    _p.setString('lang', v);
    _bump();
  }

  /// false = landscape (default pri prvom pokretanju), true = portrait.
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

  static int get aiLevel => _p.getInt('aiLevel') ?? 3;
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
