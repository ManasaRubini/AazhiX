import 'package:flutter/material.dart';

class AppTheme {
  
  static ThemeData darkTheme = ThemeData(
    
  
    scaffoldBackgroundColor: const Color.fromARGB(255, 184, 210, 248),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 176, 208, 255),
      elevation: 0,
    ),

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.cyan,
      brightness: Brightness.dark,
    ),

    cardColor: const Color.fromARGB(255, 168, 202, 252),

    useMaterial3: true,
  );
}