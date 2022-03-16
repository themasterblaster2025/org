import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'main/language/AppLocalizations.dart';
import 'main/language/BaseLanguage.dart';
import 'main/screens/SplashScreen.dart';
import 'main/store/AppStore.dart';
import 'main/utils/AppTheme.dart';
import 'main/utils/DataProviders.dart';

AppStore appStore = AppStore();
late BaseLanguage language;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripPaymentPublishKey;
  await Stripe.instance.applySettings().catchError((e) {
    log("${e.toString()}");
  });

  await initialize(aLocaleLanguageList: languageList());

  appStore.setLogin(getBoolAsync(IS_LOGGED_IN),isInitializing: true);
  appStore.setUserEmail(getStringAsync(USER_EMAIL),isInitialization: true);
  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == appThemeMode.ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == appThemeMode.ThemeModeDark) {
    appStore.setDarkMode(true);
  }

  await OneSignal.shared.setAppId(mOneSignalAppId);

  saveOneSignalPlayerId();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
      supportedLocales: LanguageDataModel.languageLocales(),
      localizationsDelegates: [AppLocalizations(), GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
      localeResolutionCallback: (locale, supportedLocales) => locale,
      locale: Locale(appStore.selectedLanguage.validate(value: defaultLanguage)),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
