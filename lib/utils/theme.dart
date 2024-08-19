import 'package:flutter/material.dart';

// Day Theme
final ThemeData dayTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blueAccent,
  backgroundColor: Colors.white,
  scaffoldBackgroundColor: Colors.blue[50],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueAccent,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
        color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
    bodyText1: TextStyle(color: Colors.black, fontSize: 20),
    bodyText2: TextStyle(color: Colors.grey[700], fontSize: 18),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.orangeAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(
        brightness: Brightness.light,
        primary: Colors.blueAccent,
        secondary: Colors.orangeAccent,
      )
      .copyWith(secondary: Colors.orangeAccent),
);

// Night Theme
final ThemeData nightTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  backgroundColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
    bodyText1: TextStyle(color: Colors.white, fontSize: 20),
    bodyText2: TextStyle(color: Colors.grey[400], fontSize: 18),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blueAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(
        brightness: Brightness.dark,
        primary: Colors.blueAccent,
        secondary: Colors.greenAccent,
      )
      .copyWith(secondary: Colors.greenAccent),
);
