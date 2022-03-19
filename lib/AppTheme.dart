import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: createMaterialColor(colorPrimary),
    primaryColor: colorPrimary,
    scaffoldBackgroundColor: Colors.white,
    accentColor: colorPrimary,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: colorPrimary,
      unselectedItemColor: black,
    ),
    //fontFamily: GoogleFonts.rajdhani().fontFamily,
    iconTheme: IconThemeData(color: colorPrimary),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: viewLineColor,
    cardColor: Colors.white,
    tabBarTheme: TabBarTheme(labelColor: Colors.black),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    dialogTheme: DialogTheme(shape: dialogShape()),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
    colorScheme: ColorScheme.light(
      primary: colorPrimary,
    ),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: createMaterialColor(colorPrimary),
    primaryColor: colorPrimary,
    scaffoldBackgroundColor: scaffoldColorDark,
    accentColor: colorPrimary,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.red,
      unselectedItemColor: white,
      selectedItemColor: colorPrimary,
    ),
    //fontFamily: GoogleFonts.rajdhani().fontFamily,
    iconTheme: IconThemeData(color: Colors.white),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: scaffoldSecondaryDark,
    tabBarTheme: TabBarTheme(labelColor: Colors.white),
    appBarTheme: AppBarTheme(
      color: scaffoldColorDark,
      brightness: Brightness.dark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: scaffoldColorDark,
      ),
    ),
    dialogTheme: DialogTheme(shape: dialogShape()),
    snackBarTheme: SnackBarThemeData(backgroundColor: appButtonColorDark),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: appButtonColorDark),
    colorScheme: ColorScheme.dark(
      primary: colorPrimary,
    ),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
