import 'BaseLanguage.dart';

class LanguageHi extends BaseLanguage {
  @override String get app_name => "मांग पर स्थानीय वितरण प्रणाली";

  @override String get language => "भाषा";

  @override String get confirmation => "पुष्टीकरण";

  @override String get cancel => "रद्द करें";

  @override String get create => "सृजन करना";

  @override String get filter => "फ़िल्टर";

  @override String get reset => "रीसेट";

  @override String get status => "स्थिति";

  @override String get date => "तारीख";

  @override String get from => "से";

  @override String get to => "प्रति";

  @override String get to_date_validation_msg => "तारीख से तारीख के बाद होना चाहिए";

  @override String get apply_filter => "फिल्टर लागू करें";

  @override String get payment => "भुगतान";

  @override String get payment_method => "भुगतान की विधि";

  @override String get pay_now => "अब भुगतान करें";

  @override String get please_select_city => "कृपया शहर का चयन करें";

  @override String get select_region => "क्षेत्र का चयन करें'";
  @override String get country => "देश";
  @override String get city => "शहर";
  @override String get logout_confirmation_msg => "क्या आप लॉग आउट करना चाहते हैं ?";
  @override String get yes => "हां";
  @override String get picked_at => "पर चुना";
  @override String get delivered_at => "पर सुपुर्दगी";
  @override String get track_order => "ऑर्डर पर नज़र रखें";

  @override String get delivery_now => "अब वितरित करना";
  @override String get schedule => "अनुसूची";
  @override String get pick_time => "समय निकालना";
  @override String get end_time_validation_msg => "एंडटाइम स्टार्टटाइम के बाद होना चाहिए";
  @override String get deliver_time => "समय प्रदान करना";
  @override String get weight => "वज़न";
  @override String get parcel_type => "पार्सल प्रकार";
  @override String get pick_up_information => "पिकअप जानकारी";
  @override String get address => "पता";
  @override String get contact_number => "संपर्क संख्या";
  @override String get description => "विवरण";
  @override String get delivery_information => "वितरण की जानकारी";
  @override String get package_information => "पैकेज जानकारी";
  @override String get pickup => "पिक अप";
  @override String get delivery => "वितरण";
  @override String get delivery_charge => "डिलीवरी चार्ज";
  @override String get distance_charge => "दूरी प्रभार";
  @override String get weight_charge => "वजन प्रभार";
  @override String get extra_charges => "अतिरिक्त शुल्क";
  @override String get total => "संपूर्ण";
  @override String get cash_payment => "नकद भुगतान";
  @override String get online_payment => "ऑनलाइन भुगतान";
  @override String get payment_collect_from => "से भुगतान एकत्रित करें";
  @override String get save_draft_confirmation_msg => "क्या आप वाकई ड्राफ्ट के रूप में सहेजना चाहते हैं?";
  @override String get save_draft => "मसौदा सेव करें";
  @override String get create_order => "आदेश बनाएँ";
  @override String get previous => "पहले का";
  @override String get pickup_current_validation_msg => "पिकअप समय वर्तमान समय के बाद होना चाहिए";
  @override String get pickup_deliver_validation_msg => "पिकअप समय समय देने से पहले होना चाहिए '";
  @override String get create_order_confirmation_msg => "क्या आप वाकई ऑर्डर बनाना चाहते हैं?";

  @override String get draft_order => "ड्राफ्ट आदेश";
  @override String get order_details => "ऑर्डर का विवरण";
  @override String get distance => "दूरी";
  @override String get parcel_details => "पार्सल विवरण";
  @override String get about_delivery_man => "डिलीवरी मैन के बारे में";
  @override String get about_user => "उपयोगकर्ता के बारे में";
  @override String get return_order => "वापसी आदेश";
  @override String get cancel_order => "आदेश रद्द";
  @override String get lbl_return => "वापसी";

  @override String get change_password => "पासवर्ड बदलें";
  @override String get old_password => "पुराना पासवर्ड";
  @override String get new_password => "नया पासवर्ड";
  @override String get confirm_password => "पासवर्ड की पुष्टि कीजिये";
  @override String get password_not_match => "पासवर्ड मैच नहीं कर रहा है";
  @override String get save_changes => "परिवर्तनों को सुरक्षित करें";
  @override String get profile_update_msg => "प्रोफाइल को सफलतापूर्वक अपडेट किया गया";
  @override String get edit_profile => "प्रोफ़ाइल संपादित करें";
  @override String get not_change_email => "आप ईमेल आईडी नहीं बदल सकते";
  @override String get username => "उपयोगकर्ता नाम";
  @override String get not_change_username => "आप उपयोगकर्ता नाम नहीं बदल सकते";
  @override String get forgot_password => "पासवर्ड भूल गए";
  @override String get email => "ईमेल";
  @override String get submit => "प्रस्तुत करना";
  @override String get user_not_approve_msg => "आप प्रोफ़ाइल समीक्षा अधीन हैं। कुछ समय प्रतीक्षा करें या अपने व्यवस्थापक से संपर्क करें।";
  @override String get sign_in_account => "साइन इन खाता";
  @override String get sign_in_to_continue => "जारी रखने के लिए साइन इन करें";
  @override String get password => "कुंजिका";
  @override String get forgot_password_que => "पासवर्ड भूल गए ?";
  @override String get sign_in => "साइन इन करें";
  @override String get or => "या";
  @override String get continue_with_google => "Google के साथ जारी रखें";
  @override String get do_not_have_account => "खाता नहीं है?";
  @override String get sign_up => "साइन अप करें";
}
