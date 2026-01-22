import 'package:flutter/foundation.dart';

class AppServerConfig {
  static String get baseUrl {
    if (kReleaseMode) {
     return 'https://courierstoday.com';
    } else if (kProfileMode) {
      return 'https://courierstoday.com';
    } else {
      return 'https://courierstoday.com/adminHub';
    }
  }
}
