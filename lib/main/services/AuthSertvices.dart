import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../delivery/components/OTPDialog.dart';
import '../../main/screens/LoginScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../components/UserCitySelectScreen.dart';
import '../models/CityListModel.dart';
import '../models/LoginResponse.dart';
import '../network/RestApis.dart';
import '../screens/VerificationScreen.dart';
import '../utils/Constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  Future<void> updateUserData(UserData user) async {
    userService.updateDocument({
      'player_id': getStringAsync(PLAYER_ID),
      'updatedAt': Timestamp.now(),
    }, user.uid);
  }

  Future<User?> createAuthUser(String? email, String? password) async {
    User? userCredential;
    try {
      await _auth.createUserWithEmailAndPassword(email: email!, password: password!).then((value) {
        userCredential = value.user!;
      });
    } on FirebaseException catch (error) {
      if (error.code == "ERROR_EMAIL_ALREADY_IN_USE" || error.code == "account-exists-with-different-credential" || error.code == "email-already-in-use") {
        try {
          await _auth.signInWithEmailAndPassword(email: email!, password: password!).then((value) {
            userCredential = value.user!;
          });
        } on FirebaseException catch (error) {
          toast(error.message);
        }
      } else {
        toast(error.message);
      }
    }
    return userCredential;
  }

  Future<void> signUpWithEmailPassword(context,
      {String? name, String? email, String? password, LoginResponse? userData, String? mobileNumber, String? lName, String? userName, bool? isOTP, String? userType, bool isAddUser = false}) async {
    try {
      createAuthUser(email, password).then((user) async {
        if (user != null) {
          UserData userModel = UserData();

          /// Create user
          userModel.uid = user.uid;
          userModel.email = user.email;
          userModel.contactNumber = userData!.data!.contactNumber;
          userModel.name = userData.data!.name;
          userModel.username = userData.data!.username;
          userModel.userType = userData.data!.userType;
          userModel.longitude = userData.data!.longitude;
          userModel.latitude = userData.data!.longitude;
          userModel.countryName = userData.data!.countryName;
          userModel.cityName = userData.data!.cityName;
          userModel.status = userData.data!.status;
          userModel.playerId = userData.data!.playerId;
          userModel.profileImage = userData.data!.profileImage;
          userModel.createdAt = Timestamp.now().toDate().toString();
          userModel.updatedAt = Timestamp.now().toDate().toString();
          userModel.playerId = getStringAsync(PLAYER_ID);
          await userService.addDocumentWithCustomId(user.uid, userModel.toJson()).then((value) async {
            updateUid(user.uid).then((value) async {
              if (userModel.userType == DELIVERY_MAN) {
                appStore.setLogin(false);
                appStore.setLoading(false);
                LoginScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
              } else {
                Map request = {"email": userModel.email, "password": password};
                await logInApi(request).then((res) async {
                  await signInWithEmailPassword(context, email: email.validate(), password: password.validate()).then((value) {
                    updateUid(getStringAsync(UID)).then((value) {
                      log("value...." + value.toString());
                    });
                    appStore.setLoading(false);
                    UserCitySelectScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
                  });
                }).catchError((e) {
                  appStore.setLoading(false);
                  log(e.toString());
                  toast(e.toString());
                });
              }
            });
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString());
          });
        } else {
          appStore.setLoading(false);
          throw 'Something went wrong';
        }
      }).catchError((e){
        appStore.setLoading(false);
      });
    } on FirebaseException catch (error) {
      appStore.setLoading(false);
      toast(error.message);
    }
  }

  Future<void> signInWithEmailPassword(context, {required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      appStore.setLoading(true);
      final User user = value.user!;
      UserData userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);

      appStore.setLoading(true);
      //Login Details to SharedPreferences
      setValue(UID, userModel.uid.validate());
      setValue(USER_EMAIL, userModel.email.validate());
      setValue(IS_LOGGED_IN, true);
    }).catchError((e) {
      log(e.toString());
    });
  }

  Future<void> loginFromFirebaseUser(User currentUser, {LoginResponse? loginDetail, String? fullName, String? fName, String? lName}) async {
    UserData userModel = UserData();

    if (await userService.isUserExist(loginDetail!.data!.email)) {
      ///Return user data
      await userService.userByEmail(loginDetail.data!.email).then((user) async {
        userModel = user;
        appStore.setUserEmail(userModel.email.validate());
        appStore.setUId(userModel.uid.validate());

        await updateUserData(user);
      }).catchError((e) {
        log(e);
        throw e;
      });
    } else {
      /// Create user
      userModel.uid = currentUser.uid.validate();
      userModel.id = loginDetail.data!.id.validate();
      userModel.email = loginDetail.data!.email.validate();
      userModel.name = loginDetail.data!.name.validate();
      userModel.contactNumber = loginDetail.data!.contactNumber.validate();
      userModel.username = loginDetail.data!.username.validate();
      userModel.email = loginDetail.data!.email.validate();
      userModel.userType = CLIENT;

      if (isIOS) {
        userModel.username = fullName;
      } else {
        userModel.username = loginDetail.data!.username.validate();
      }

      userModel.contactNumber = loginDetail.data!.contactNumber.validate();
      userModel.profileImage = loginDetail.data!.profileImage.validate();
      userModel.playerId = getStringAsync(PLAYER_ID);

      setValue(UID, currentUser.uid.validate());
      log(getStringAsync(UID));
      setValue(USER_EMAIL, userModel.email.validate());
      setValue(IS_LOGGED_IN, true);

      log(userModel.toJson());

      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) {
        //
      }).catchError((e) {
        throw e;
      });
    }
  }

/*  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      //Authentication
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      googleSignIn.signOut();

      String firstName = '';
      String lastName = '';
      if (currentUser.displayName.validate().split(' ').length >= 1) firstName = currentUser.displayName.splitBefore(' ');
      if (currentUser.displayName.validate().split(' ').length >= 2) lastName = currentUser.displayName.splitAfter(' ');
      Map req = {
        "email": currentUser.email,
        "login_type": LoginTypeGoogle,
        "user_type": RIDER,
        "first_name": firstName,
        "last_name": lastName,
        "username": (firstName + lastName).toLowerCase(),
        "uid": currentUser.uid,
        'accessToken': googleSignInAuthentication.accessToken,
        if (!currentUser.phoneNumber.isEmptyOrNull) 'contact_number': currentUser.phoneNumber.validate(),
      };

      await logInApi(req, isSocialLogin: true).then((value) async {
        Navigator.pop(context);
        sharedPreferences.setString(UID, currentUser.uid);
        await appStore.setUserProfile(currentUser.photoURL.toString());
        await sharedPref.setString(USER_PROFILE_PHOTO, currentUser.photoURL.toString());
        if (value.data!.contactNumber.isEmptyOrNull) {
          launchScreen(context, EditProfileScreen(isGoogle: true), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          if (value.data!.uid.isEmptyOrNull) {
            await updateProfile(
              uid: sharedPref.getString(UID).toString(),
              userEmail: currentUser.email.validate(),
            ).then((value) {
              launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
          }
        }
      }).catchError((e) {
        log(e.toString());
        throw e;
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }*/
}

getCountryDetailApiCall(int countryId, context) async {
  await getCountryDetail(countryId).then((value) {
    setValue(COUNTRY_DATA, value.data!.toJson());
  }).catchError((error) {});
}

getCityDetailApiCall(int cityId, context) async {
  await getCityDetail(cityId).then((value) async {
    await setValue(CITY_DATA, value.data!.toJson());
    if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
      if (getBoolAsync(OTP_VERIFIED)) {
        if (getStringAsync(USER_TYPE) == CLIENT) {
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          DeliveryDashBoard().launch(context, isNewTask: true);
        }
      } else {
        VerificationScreen().launch(context, isNewTask: true);
      }
    } else {
      UserCitySelectScreen().launch(context, isNewTask: true);
    }
  }).catchError((error) {});
}

Future deleteUserFirebase() async {
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }
}

sendOtp(BuildContext context, {required String phoneNumber, required Function(String) onUpdate}) async {
  appStore.setLoading(true);
  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        appStore.setLoading(false);
        toast(language.verificationCompleted);
      },
      verificationFailed: (FirebaseAuthException e) {
        appStore.setLoading(false);
        if (e.code == 'invalid-phone-number') {
          toast(language.phoneNumberInvalid);
          throw language.phoneNumberInvalid;
        } else {
          toast(e.message.toString());
          throw e.message.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        appStore.setLoading(false);
        toast(language.codeSent);
        onUpdate.call(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        appStore.setLoading(false);
      },
    );
  } on FirebaseException catch (error) {
    appStore.setLoading(false);
    toast(error.message);
  }
}
