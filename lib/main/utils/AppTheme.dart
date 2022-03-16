import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: colorPrimary,
      iconTheme: IconThemeData(color: Colors.black),
      dividerColor: viewLineColor,
      colorScheme: ColorScheme(
        primary: colorPrimary,
        primaryVariant: createMaterialColor(colorPrimary),
        secondary: Colors.blue,
        secondaryVariant: createMaterialColor(Colors.blue),
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.redAccent,
        brightness: Brightness.light,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius(20), side: BorderSide(width: 1)),
        checkColor: MaterialStateProperty.all(Colors.white),
        fillColor: MaterialStateProperty.all(colorPrimary),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      //textTheme: GoogleFonts.poppinsTextTheme(),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ));

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey,
    iconTheme: IconThemeData(color: Colors.white),
    colorScheme: ColorScheme(
      primary: colorPrimary,
      primaryVariant: createMaterialColor(colorPrimary),
      secondary: Colors.blue,
      secondaryVariant: createMaterialColor(Colors.blue),
      surface: Colors.black,
      background: Colors.black,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.redAccent,
      brightness: Brightness.dark,
    ),
    dividerColor: Colors.white24,
    //textTheme: GoogleFonts.poppinsTextTheme(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
