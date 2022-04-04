import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get appName;

  String get language;

  String get confirmation;

  String get cancel;

  String get create;

  String get filter;

  String get reset;

  String get status;

  String get date;

  String get from;

  String get applyFilter;

  String get to;

  String get toDateValidationMsg;

  String get payment;

  String get paymentMethod;

  String get payNow;

  String get pleaseSelectCity;

  String get selectRegion;

  String get country;

  String get city;

  String get logoutConfirmationMsg;

  String get yes;

  String get pickedAt;

  String get deliveredAt;

  String get trackOrder;

  String get deliveryNow;

  String get schedule;

  String get pickTime;

  String get endTimeValidationMsg;

  String get deliverTime;

  String get weight;

  String get parcelType;

  String get pickupInformation;

  String get address;

  String get contactNumber;

  String get description;

  String get deliveryInformation;

  String get packageInformation;

  String get pickup;

  String get delivery;

  String get deliveryCharge;

  String get distanceCharge;

  String get weightCharge;

  String get extraCharges;

  String get total;

  String get cashPayment;

  String get onlinePayment;

  String get paymentCollectFrom;

  String get saveDraftConfirmationMsg;

  String get saveDraft;

  String get createOrder;

  String get previous;

  String get pickupCurrentValidationMsg;

  String get pickupDeliverValidationMsg;

  String get createOrderConfirmationMsg;

  String get draftOrder;

  String get orderDetails;

  String get distance;

  String get parcelDetails;

  String get aboutDeliveryMan;

  String get aboutUser;

  String get returnOrder;

  String get cancelOrder;

  String get lblReturn;

  String get changePassword;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get passwordNotMatch;

  String get saveChanges;

  String get profileUpdateMsg;

  String get editProfile;

  String get notChangeEmail;

  String get username;

  String get notChangeUsername;

  String get forgotPassword;

  String get email;

  String get submit;

  String get userNotApproveMsg;

  String get signInAccount;

  String get signInToContinue;

  String get password;

  String get forgotPasswordQue;

  String get signIn;

  String get or;

  String get continueWithGoogle;

  String get doNotHaveAccount;

  String get signUp;

  String get name;

  String get notification;

  String get selectUsertypeMsg;

  String get createAnAccount;

  String get signUpToContinue;

  String get userType;

  String get client;

  String get deliveryMan;

  String get alreadyHaveAnAccount;

  String get light;

  String get dark;

  String get systemDefault;

  String get theme;

  String get skip;

  String get getStarted;

  String get profile;

  String get trackOrderLocation;

  String get track;

  String get active;

  String get pickUp;

  String get departed;

  String get orderPickupSuccessfully;

  String get imagePickToCamera;

  String get imagePicToGallery;

  String get orderDeliver;

  String get orderPickup;

  String get info;

  String get paymentCollectFromDelivery;

  String get paymentCollectFromPickup;

  String get pickupDatetime;

  String get hour;

  String get deliveryDatetime;

  String get pickupTimeSignature;

  String get save;

  String get clear;

  String get deliveryTimeSignature;

  String get reason;

  String get pickupDelivery;

  String get selectPickupTimeMsg;

  String get selectDeliveryTimeMsg;

  String get selectPickupSignMsg;

  String get selectDeliverySignMsg;

  String get selectReasonMsg;

  String get orderCancelledSuccessfully;

  String get collectPaymentConfirmationMsg;

  String get trackingOrder;

  String get assign;

  String get pickedUp;

  String get arrived;

  String get completed;

  String get cancelled;

  String get allowLocationPermission;

  String get walkThrough1Title;

  String get walkThrough2Title;

  String get walkThrough3Title;

  String get walkThrough1Subtitle;

  String get walkThrough2Subtitle;

  String get walkThrough3Subtitle;

  String get order;

  String get account;

  String get drafts;

  String get aboutUs;

  String get helpAndSupport;

  String get logout;

  String get changeLocation;

  String get selectCity;

  String get next;

  String get fieldRequiredMsg;

  String get emailInvalid;

  String get passwordInvalid;

  String get usernameInvalid;

  String get writeReasonHere;

  String get areYouSureWantToArrive;

  String get note;

  String get courierWillPickupAt;

  String get courierWillDeliverAt;

  String get confirmDelivery;

  String get orderAssignConfirmation;

  String get orderPickupConfirmation;

  String get orderDepartedConfirmation;

  String get orderCreateConfirmation;

  String get orderCompleteConfirmation;

  String get orderCancelConfirmation;

  String get id;

  String get contactNumberValidation;

  String get rememberMe;

  String get becomeADeliveryBoy;

  String get orderHistory;

  String get no;

  String get confirmPickup;

  String get version;

  String get contactUs;

  String get purchase;

  String get privacyPolicy;

  String get termAndCondition;
}
