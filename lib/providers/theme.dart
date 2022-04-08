// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const int fbtPrimaryValue = 0xFFA83333;
const fbtPrimColor = Color(0xFFA83333);
const MaterialColor ricPrimaryMaterialColor = Colors.blue;

ThemeData getThemeData() {
  return ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: Colors.greenAccent,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1)));
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  ButtonStyle get roundButtonStyle => ElevatedButton.styleFrom(
      minimumSize: Size(150, 60),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(
          30,
        ),
      )));

  ButtonStyle get roundOutlinedButtonStyle => OutlinedButton.styleFrom(
      minimumSize: Size(150, 60),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(
          30,
        ),
      )));

  ThemeData get currentThemeData =>
      _isDark ? ThemeData.dark() : getThemeData(); //ThemeData.light();

  static ThemeProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<ThemeProvider>(context, listen: listen);
}
