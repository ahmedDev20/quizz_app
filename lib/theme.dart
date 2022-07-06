import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var appTheme = ThemeData(
  fontFamily: GoogleFonts.poppins().fontFamily,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepOrange,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.black87,
  ),
  brightness: Brightness.dark,
  textTheme: const TextTheme(
    bodyText1: TextStyle(fontSize: 18),
    bodyText2: TextStyle(fontSize: 16),
    button: TextStyle(
      letterSpacing: 1.5,
      fontWeight: FontWeight.bold,
    ),
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    subtitle1: TextStyle(
      color: Colors.grey,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    labelStyle: TextStyle(color: Colors.white),
    fillColor: Colors.white,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
  buttonTheme: const ButtonThemeData(),
);
