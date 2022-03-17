import 'BaseLanguage.dart';

class LanguageAr extends BaseLanguage {
  @override String get app_name => "عند الطلب نظام التسليم المحلي";

  @override String get language => "لغة";

  @override String get confirmation => "تأكيد";

  @override String get cancel => "يلغي";

  @override String get create => "خلق";

  @override String get filter => "منقي";

  @override String get reset => "إعادة ضبط";

  @override String get status => "حالة";

  @override String get date => "تاريخ";

  @override String get from => "من";

  @override String get to => "ل";

  @override String get to_date_validation_msg => "حتى الآن يجب أن يكون بعد تاريخ";

  @override String get apply_filter => "تطبيق مرشح";

  @override String get payment => "دفع";

  @override String get payment_method => "طرق الدفع";

  @override String get pay_now => "ادفع الآن";

  @override String get please_select_city => "يرجى اختيار المدينة";

  @override String get select_region => "اختر المنطقة'";
  @override String get country => "دولة";
  @override String get city => "مدينة";
  @override String get logout_confirmation_msg => "هل أنت متأكد أنك تريد تسجيل الخروج ؟";
  @override String get yes => "نعم";
  @override String get picked_at => "اختار في";
  @override String get delivered_at => "تسليمها في";
  @override String get track_order => "ترتيب المسار";

  @override String get delivery_now => "تقديم الآن";
  @override String get schedule => "برنامج";
  @override String get pick_time => "اختر وقت";
  @override String get end_time_validation_msg => "يجب أن يكون الوقت بعد وقت البدء";
  @override String get deliver_time => "وقت التوصيل";
  @override String get weight => "وزن";
  @override String get parcel_type => "الطردال نوع";
  @override String get pick_up_information => "معلومات بيك اب";
  @override String get address => "عنوان";
  @override String get contact_number => "رقم الاتصال";
  @override String get description => "وصف";
  @override String get delivery_information => "معلومات التوصيل";
  @override String get package_information => "حزمة معلومات";
  @override String get pickup => "يلتقط";
  @override String get delivery => "توصيل";
  @override String get delivery_charge => "رسوم التوصيل";
  @override String get distance_charge => "تهمة المسافة";
  @override String get weight_charge => "تهمة الوزن";
  @override String get extra_charges => "رسوم إضافية";
  @override String get total => "المجموع";
  @override String get cash_payment => "دفع نقدا";
  @override String get online_payment => "الدفع الالكتروني";
  @override String get payment_collect_from => "يجمع الدفع من";
  @override String get save_draft_confirmation_msg => "هل أنت متأكد أنك تريد حفظ كمسودة؟";
  @override String get save_draft => "حفظ المسودة";
  @override String get create_order => "إنشاء النظام";
  @override String get previous => "سابق";
  @override String get pickup_current_validation_msg => "يجب أن يكون وقت الالتقاط بعد الوقت الحالي";
  @override String get pickup_deliver_validation_msg => "يجب أن يكون وقت الالتقاط قبل تقديم الوقت";
  @override String get create_order_confirmation_msg => "هل أنت متأكد من أنك تريد إنشاء ترتيب؟";

  @override String get draft_order => "مشروع النظام";
  @override String get order_details => "تفاصيل الطلب";
  @override String get distance => "مسافه: بعد";
  @override String get parcel_details => "تفاصيل الطرود";
  @override String get about_delivery_man => "حول رجل التسليم";
  @override String get about_user => "عن المستخدم";
  @override String get return_order => "ترتيب العودة";
  @override String get cancel_order => "الغاء الطلب";
  @override String get lbl_return => "إرجاع";

  @override String get change_password => "تغيير كلمة المرور";
  @override String get old_password => "كلمة المرور القديمة";
  @override String get new_password => "كلمة مرور جديدة";
  @override String get confirm_password => "تأكيد كلمة المرور";
  @override String get password_not_match => "كلمة السر غير متطابقة";
  @override String get save_changes => "حفظ التغييرات";
  @override String get profile_update_msg => "تم تحديث الملف الشخصي بنجاح";
  @override String get edit_profile => "تعديل الملف الشخصي";
  @override String get not_change_email => "لا يمكنك تغيير معرف البريد الإلكتروني";
  @override String get username => "اسم المستخدم";
  @override String get not_change_username => "لا يمكنك تغيير اسم المستخدم";
  @override String get forgot_password => "هل نسيت كلمة السر";
  @override String get email => "بريد الالكتروني";
  @override String get submit => "يقدم";
  @override String get user_not_approve_msg => "أنت ملف التعريف قيد المراجعة. انتظر بعض الوقت أو جهة اتصال المسؤول الخاص بك.";
  @override String get sign_in_account => "تسجيل الدخول";
  @override String get sign_in_to_continue => "تسجيل الدخول للمتابعة";
  @override String get password => "كلمة المرور";
  @override String get forgot_password_que => "هل نسيت كلمة السر ؟";
  @override String get sign_in => "تسجيل الدخول";
  @override String get or => "أو";
  @override String get continue_with_google => "تواصل مع جوجل";
  @override String get do_not_have_account => "لا يوجد حساب؟";
  @override String get sign_up => "اشتراك";
}
