import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get app_name;

  String get language;

  String get confirmation;

  String get cancel;

  String get create;

  String get filter;

  String get reset;

  String get status;

  String get date;

  String get from;

  String get to;

  String get to_date_validation_msg;

  String get apply_filter;

  String get payment;

  String get payment_method;

  String get pay_now;

  String get please_select_city;

  String get select_region;

  String get country;

  String get city;

  String get logout_confirmation_msg;

  String get yes;

  String get picked_at;

  String get delivered_at;

  String get track_order;

  String get delivery_now;

  String get schedule;

  String get pick_time;

  String get end_time_validation_msg;

  String get deliver_time;

  String get weight;

  String get parcel_type;

  String get pick_up_information;

  String get address;

  String get contact_number;

  String get description;

  String get delivery_information;

  String get package_information;

  String get pickup;

  String get delivery;

  String get delivery_charge;

  String get distance_charge;

  String get weight_charge;

  String get extra_charges;

  String get total;

  String get cash_payment;

  String get online_payment;

  String get payment_collect_from;

  String get save_draft_confirmation_msg;

  String get save_draft;

  String get create_order;

  String get previous;

  String get pickup_current_validation_msg;

  String get pickup_deliver_validation_msg;

  String get create_order_confirmation_msg;

  String get draft_order;

  String get order_details;

  String get distance;

  String get parcel_details;

  String get about_delivery_man;

  String get about_user;

  String get return_order;

  String get cancel_order;

  String get lbl_return;

  String get change_password;

  String get old_password;

  String get new_password;

  String get confirm_password;

  String get password_not_match;

  String get save_changes;

  String get profile_update_msg;

  String get edit_profile;

  String get not_change_email;

  String get username;

  String get not_change_username;

  String get forgot_password;

  String get email;

  String get submit;

  String get user_not_approve_msg;

  String get sign_in_account;

  String get sign_in_to_continue;

  String get password;

  String get forgot_password_que;

  String get sign_in;

  String get or;

  String get continue_with_google;

  String get do_not_have_account;

  String get sign_up;

  String get name;

  String get notification;

  String get select_usertype_msg;

  String get create_an_account;

  String get sign_up_to_continue;

  String get user_type;

  String get client;

  String get delivery_man;

  String get already_have_an_account;

  String get light;

  String get dark;

  String get system_default;

  String get theme;

  String get skip;

  String get get_started;

  String get profile;

  String get track_order_location;

  String get track;

  String get active;

  String get pick_up;

  String get departed;

  String get order_pickup_successfully;

  String get image_pick_to_camera;

  String get image_pic_to_gallery;

  String get order_deliver;

  String get order_pickup;

  String get info;

  String get payment_collect_from_delivery;

  String get payment_collect_from_pickup;

  String get pickup_datetime;

  String get hour;

  String get delivery_datetime;

  String get pickup_time_signature;

  String get save;

  String get clear;

  String get delivery_time_signature;

  String get reason;

  String get pickup_delivery;

  String get select_pickup_time_msg;

  String get select_delivery_time_msg;

  String get select_pickup_sign_msg;

  String get select_delivery_sign_msg;

  String get select_reason_msg;

  String get order_cancelled_successfully;

  String get collect_payment_confirmation_msg;

  String get tracking_order;

  String get assign;

  String get picked_up;

  String get arrived;

  String get completed;

  String get cancelled;

  String get allow_location_permission;

  String get walk_through1_title;

  String get walk_through2_title;

  String get walk_through3_title;

  String get walk_through1_subtitle;

  String get walk_through2_subtitle;

  String get walk_through3_subtitle;

  String get order;

  String get account;

  String get drafts;

  String get about_us;

  String get help_and_support;

  String get logout;

  String get change_location;

  String get select_city;

  String get next;

  String get field_required_msg;

  String get email_invalid;

  String get password_invalid;

  String get username_invalid;

  String get write_reason_here;
}
