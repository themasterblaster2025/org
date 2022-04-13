import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:nb_utils/nb_utils.dart';

List<String> userCancelOrderReasonList = [
  "Place order by mistake",
  "Delivery time is too long",
  "Duplicate order",
  "Change of mind",
  "Change order",
  "Incorrect/incomplete address",
  "Other",
];

List<String> deliveryBoyCancelOrderReasonList = [
  "Incorrect/incomplete address",
  "Wrong contact information",
  "Damage courier",
  "Payment issue",
  "Person not available on location",
  "Invalid courier package",
  "Courier package is not as per order",
  "Other",
];

List<String> returnOrderReasonList = [
  "Invalid order",
  "Damage courier",
  "Sent wrong courier",
  "Not as order",
  "Other",
];

List<LanguageDataModel> languageList() {
  return [
    // TODO full language code change
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 1, name: 'Spanish', subTitle: 'Española', languageCode: 'es', fullLanguageCode: 'es-ES', flag: 'assets/flag/ic_spain.png'),
    LanguageDataModel(id: 2, name: 'Afrikaans', subTitle: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'af-AF', flag: 'assets/flag/ic_south_africa.png'),
    LanguageDataModel(id: 3, name: 'French', subTitle: 'Français', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_france.png'),
    LanguageDataModel(id: 1, name: 'German', subTitle: 'Deutsch', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_germany.png'),
    LanguageDataModel(id: 2, name: 'Indonesian', subTitle: 'bahasa Indonesia', languageCode: 'id', fullLanguageCode: 'id-ID', flag: 'assets/flag/ic_indonesia.png'),
    LanguageDataModel(id: 3, name: 'Portuguese', subTitle: 'Português', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'assets/flag/ic_portugal.png'),
    LanguageDataModel(id: 1, name: 'Turkish', subTitle: 'Türkçe', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'assets/flag/ic_turkey.png'),
    LanguageDataModel(id: 2, name: 'vietnamese', subTitle: 'Tiếng Việt', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'assets/flag/ic_vitnam.png'),
    LanguageDataModel(id: 3, name: 'Dutch', subTitle: 'Nederlands', languageCode: 'nl', fullLanguageCode: 'nl-NL', flag: 'assets/flag/ic_dutch.png'),
  ];
}

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(image: 'assets/walk_through1.png', title: language.walkThrough1Title, subTitle: language.walkThrough1Subtitle));
  list.add(WalkThroughItemModel(image: 'assets/walk_through2.png', title: language.walkThrough2Title, subTitle: language.walkThrough2Subtitle));
  list.add(WalkThroughItemModel(image: 'assets/walk_through3.png', title: language.walkThrough3Title, subTitle: language.walkThrough3Subtitle));
  return list;
}

