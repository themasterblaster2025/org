import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/main/services/OrdersMessageService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main/models/models.dart';
import '../main/screens/SplashScreen.dart';
import '../main/utils/Constants.dart';
import 'extensions/common.dart';
import 'extensions/shared_pref.dart';
import 'languageConfiguration/AppLocalizations.dart';
import 'languageConfiguration/BaseLanguage.dart';
import 'languageConfiguration/LanguageDataConstant.dart';
import 'languageConfiguration/LanguageDefaultJson.dart';
import 'languageConfiguration/ServerLanguageResponse.dart';
import 'main/models/FileModel.dart';
import 'main/network/RestApis.dart';
import 'main/screens/NoInternetScreen.dart';
import 'main/services/AuthServices.dart';
import 'main/services/NotificationService.dart';
import 'main/services/UserServices.dart';
import 'main/store/AppStore.dart';
import 'main/utils/Common.dart';
import 'main/utils/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences sharedPreferences;
AppStore appStore = AppStore();
late BaseLanguage language;
// Added by SK
LanguageJsonData? selectedServerLanguageData;
List<LanguageJsonData>? defaultServerLanguageData = [];

UserService userService = UserService();
//ChatMessageService chatMessageService = ChatMessageService();
AuthServices authService = AuthServices();
OrdersMessageService ordersMessageService = OrdersMessageService();
NotificationService notificationService = NotificationService();
late List<FileModel> fileList = [];
bool isCurrentlyOnNoInternet = false;
StreamSubscription<Position>? positionStream;

bool mIsEnterKey = false;
String mSelectedImage = "assets/default_wallpaper.png";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp().then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });
  }

  // await initialize(aLocaleLanguageList: languageList());
  sharedPreferences = await SharedPreferences.getInstance();
  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode));
  try {
    appStore.setLogin(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
    appStore.setUserEmail(getStringAsync(USER_EMAIL), isInitialization: true);
    appStore.setUserProfile(getStringAsync(USER_PROFILE_PHOTO), isInitializing: true);
    FilterAttributeModel? filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    appStore.setFiltering(
        filterData.orderStatus != null || !filterData.fromDate.isEmptyOrNull || !filterData.toDate.isEmptyOrNull);
    print("===========setLanguage${appStore.selectedLanguage}");
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == appThemeMode.themeModeLight) {
      appStore.setDarkMode(false);
    } else if (themeModeIndex == appThemeMode.themeModeDark) {
      appStore.setDarkMode(true);
    }
    initJsonFile();
    oneSignalSettings();
  } catch (e) {
    print("error========${e.toString()}");
  }

  runApp(MyApp());
}

Future<void> initializeDefault() async {
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? color;
  // ThemeData _lightThemeData = lightTheme();
  //ThemeData _darkThemeData = darkTheme();
  // late StreamSubscription<Position> _streamSubscription;
  String message = 'empty';
  // void updateTheme(color) {
  //   setState(() {
  //     ColorUtils.updateColors(color);
  //     _lightThemeData = ThemeData(
  //       primarySwatch: createMaterialColor(ColorUtils.colorPrimary),
  //       primaryColor: ColorUtils.colorPrimary,
  //       scaffoldBackgroundColor: Colors.white,
  //       fontFamily: GoogleFonts.lato().fontFamily,
  //       iconTheme: IconThemeData(color: Colors.black),
  //       dialogBackgroundColor: Colors.white,
  //       unselectedWidgetColor: Colors.grey,
  //       dividerColor: dividerColor,
  //       cardColor: Colors.white,
  //       tabBarTheme: TabBarTheme(labelColor: Colors.black),
  //       appBarTheme: AppBarTheme(
  //           color: ColorUtils.colorPrimary,
  //           elevation: 0,
  //           systemOverlayStyle:
  //               SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent)),
  //       dialogTheme: DialogTheme(shape: dialogShape()),
  //       bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
  //       colorScheme: ColorScheme.light(
  //         primary: ColorUtils.colorPrimary,
  //       ),
  //     ).copyWith(
  //       pageTransitionsTheme: PageTransitionsTheme(
  //         builders: <TargetPlatform, PageTransitionsBuilder>{
  //           TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
  //           TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
  //           TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  //         },
  //       ),
  //     );
  //     _darkThemeData = ThemeData(
  //       primarySwatch: createMaterialColor(ColorUtils.colorPrimary),
  //       primaryColor: ColorUtils.colorPrimary,
  //       scaffoldBackgroundColor: ColorUtils.scaffoldColorDark,
  //       fontFamily: GoogleFonts.lato().fontFamily,
  //       iconTheme: IconThemeData(color: Colors.white),
  //       dialogBackgroundColor: ColorUtils.scaffoldSecondaryDark,
  //       unselectedWidgetColor: Colors.white60,
  //       dividerColor: Colors.white12,
  //       cardColor: ColorUtils.scaffoldSecondaryDark,
  //       tabBarTheme: TabBarTheme(labelColor: Colors.white),
  //       appBarTheme: AppBarTheme(
  //         color: ColorUtils.scaffoldSecondaryDark,
  //         elevation: 0,
  //         systemOverlayStyle: SystemUiOverlayStyle(
  //           statusBarIconBrightness: Brightness.light,
  //           statusBarColor: Colors.transparent,
  //         ),
  //       ),
  //       dialogTheme: DialogTheme(shape: dialogShape()),
  //       snackBarTheme: SnackBarThemeData(backgroundColor: ColorUtils.appButtonColorDark),
  //       bottomSheetTheme: BottomSheetThemeData(backgroundColor: ColorUtils.appButtonColorDark),
  //       colorScheme: ColorScheme.dark(
  //         primary: ColorUtils.colorPrimary,
  //       ),
  //     ).copyWith(
  //       pageTransitionsTheme: PageTransitionsTheme(
  //         builders: <TargetPlatform, PageTransitionsBuilder>{
  //           TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
  //           TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
  //           TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  //         },
  //       ),
  //     );
  //   });
  // }

  @override
  void initState() {
    super.initState();
    init();
    getColor();
  }

  getColor() async {
    await getLanguageList(0).then((value) {
      color = value.themeColor;
      appStore.setThemeColor(value.themeColor!);
      appStore.updateTheme(colorFromHex(value.themeColor!));

      setState(() {});
    });
  }

  void init() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e.contains(ConnectivityResult.none)) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        push(NoInternetScreen());
      } else {
        if (isCurrentlyOnNoInternet) {
          pop();
          isCurrentlyOnNoInternet = false;
          //   nb.toast(language.internetIsConnected);
        }
        log('connected');
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    _connectivitySubscription.cancel();
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          );
        },
        title: mAppName,
        debugShowCheckedModeBanner: false,
        theme: appStore.lightTheme,
        darkTheme: appStore.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SplashScreen(),
        supportedLocales: getSupportedLocales(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CountryLocalizations.delegate,
          AppLocalizations(),
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage.validate(value: defaultLanguageCode)),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
