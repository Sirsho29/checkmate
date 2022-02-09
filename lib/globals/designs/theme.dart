import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode currentTheme = ThemeMode.light;

  ThemeMode getCurrentThemeMode() => currentTheme;

  void changeThemeMode() {
    if (currentTheme == ThemeMode.light) {
      currentTheme = ThemeMode.dark;
    } else {
      currentTheme = ThemeMode.light;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      notifyListeners();
    });
  }

  ThemeData lightTheme() => ThemeData(
        backgroundColor: Colors.white,
        primaryColorDark: Colors.black87,
        primaryColorLight: Colors.black54,
        scaffoldBackgroundColor: Color.fromRGBO(69, 73, 64, 1),
        // primaryColor: Colors.black54,
        colorScheme: const ColorScheme(
          primary: Color.fromRGBO(69, 73, 64, 1),
          primaryVariant: Color.fromRGBO(251, 238, 225, 1),
          secondary: Color.fromRGBO(87, 235, 161, 1),
          secondaryVariant: Color.fromRGBO(75, 235, 120, 1),
          error: Colors.redAccent,
          surface: Colors.redAccent,
          background: Colors.white,
          brightness: Brightness.light,
          onBackground: Colors.white,
          onError: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(150, 50),
            maximumSize: const Size(200, 50),
            primary: const Color.fromRGBO(245, 140, 110, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            textStyle: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 12.0),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(150, 50),
            maximumSize: const Size(200, 50),
            primary: Colors.white,
            side: const BorderSide(
              width: 2.0,
              color: Color.fromRGBO(251, 238, 225, 1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            textStyle: const TextStyle(
                color: Color.fromRGBO(69, 73, 64, 1),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 12.0),
          ),
        ),
      );

  ThemeData darkTheme() => ThemeData(
        backgroundColor: const Color(0x0006f11c),
        colorScheme: const ColorScheme.light(
            primary: Color(0x0006f11c),
            primaryVariant: Color(0x00fbeee1),
            secondary: Color(0x0057eba1),
            secondaryVariant: Color(0x004beb78),
            error: Colors.redAccent),
      );
}



// button: 245, 140, 110
// sec 1 : 87, 235, 161
//sec 2 : 75, 235, 120 