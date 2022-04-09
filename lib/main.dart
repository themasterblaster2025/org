import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'AppTheme.dart';
import 'main/Services/ChatMessagesService.dart';
import 'main/Services/NotificationService.dart';
import 'main/Services/UserServices.dart';
import 'main/language/AppLocalizations.dart';
import 'main/language/BaseLanguage.dart';
import 'main/models/FileModel.dart';
import 'main/models/PaymentGatewayListModel.dart';
import 'main/network/RestApis.dart';
import 'main/screens/SplashScreen.dart';
import 'main/store/AppStore.dart';
import 'main/utils/Common.dart';
import 'main/utils/DataProviders.dart';

AppStore appStore = AppStore();
late BaseLanguage language;
UserService userService = UserService();
ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
List<PaymentGatewayData> paymentGatewayList = [];
late List<FileModel> fileList = [];
String? razorKey, stripPaymentKey, stripPaymentPublishKey, flutterWavePublicKey, flutterWaveSecretKey, flutterWaveEncryptionKey, payStackPublicKey;

bool mIsEnterKey = false;
String mSelectedImage = "assets/default_wallpaper.png";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  });

  /// Get Payment Gateway Api Call
  await getPaymentGatewayList().then((value) {
    paymentGatewayList.addAll(value.data!);
    if (paymentGatewayList.isNotEmpty) {
      paymentGatewayList.forEach((element) {
        if (element.type == PAYMENT_TYPE_STRIPE) {
          stripPaymentKey = element.isTest == 1 ? element.testValue!.secretKey : element.liveValue!.secretKey;
          stripPaymentPublishKey = element.isTest == 1 ? element.testValue!.publishableKey : element.liveValue!.publishableKey;
        } else if (element.type == PAYMENT_TYPE_PAYSTACK) {
          payStackPublicKey = element.isTest == 1 ? element.testValue!.publicKey : element.liveValue!.publicKey;
        } else if (element.type == PAYMENT_TYPE_RAZORPAY) {
          razorKey = element.isTest == 1 ? element.testValue!.keyId.validate() : element.liveValue!.keyId.validate();
        } else if (element.type == PAYMENT_TYPE_FLUTTERWAVE) {
          flutterWavePublicKey = element.isTest == 1 ? element.testValue!.publicKey : element.liveValue!.publicKey;
          flutterWaveSecretKey = element.isTest == 1 ? element.testValue!.secretKey : element.liveValue!.secretKey;
          flutterWaveEncryptionKey = element.isTest == 1 ? element.testValue!.encryptionKey : element.liveValue!.encryptionKey;
        }
      });
    }
  }).catchError((error) {
    log(error.toString());
  });

  Stripe.publishableKey = stripPaymentPublishKey.validate();
  await Stripe.instance.applySettings().catchError((e) {
    log("${e.toString()}");
  });

  await initialize(aLocaleLanguageList: languageList());

  appStore.setLogin(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
  appStore.setUserEmail(getStringAsync(USER_EMAIL), isInitialization: true);
  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));
  FilterAttributeModel? filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
  appStore.setFiltering(filterData.orderStatus != null || !filterData.fromDate.isEmptyOrNull || !filterData.toDate.isEmptyOrNull);

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == appThemeMode.themeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == appThemeMode.themeModeDark) {
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
    return Observer(builder: (context) {
      return MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          );
        },
        title: language.appName,
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
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
