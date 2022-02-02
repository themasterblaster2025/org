import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mighty_delivery/main/models/ChangePasswordResponse.dart';
import 'package:mighty_delivery/main/models/LoginResponse.dart';
import 'package:mighty_delivery/main/screens/LoginScreen.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'NetworkUtils.dart';

//region Auth
Future<LoginResponse> signUpApi(Map request) async {
  Response response = await buildHttpResponse('register', request: request, method: HttpMethod.POST);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    await setValue(USER_ID, loginResponse.data!.id.validate());
    await setValue(NAME, loginResponse.data!.name.validate());
    await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    await setValue(USER_TOKEN, loginResponse.data!.api_token.validate());
    await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contact_number.validate());
    await setValue(USER_PROFILE_PHOTO, loginResponse.data!.profile_image.validate());
    await setValue(USER_TYPE, loginResponse.data!.user_type.validate());
    await setValue(USER_NAME, loginResponse.data!.username.validate());

    await appStore.setUserEmail(loginResponse.data!.email.validate());
    await appStore.setLogin(true);

    await setValue(USER_PASSWORD, request['password']);

    return loginResponse;
  }).catchError((e) {
    log(e.toString());
    throw e.toString();
  });
}

Future<LoginResponse> logInApi(Map request, {bool isSocialLogin = false}) async {
  Response response = await buildHttpResponse('login', request: request, method: HttpMethod.POST);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    /*if (request['login_type'] == LoginTypeGoogle) {
      await setValue(USER_PHOTO_URL, request['image']);
    } else {
      await setValue(USER_PHOTO_URL, loginResponse.userData!.profile_image.validate());
    }

    await setValue(GENDER, loginResponse.userData!.gender.validate());
    await setValue(NAME, loginResponse.userData!.name.validate());
    await setValue(BIO, loginResponse.userData!.bio.validate());
    await setValue(DOB, loginResponse.userData!.dob.validate());
*/

    await setValue(USER_ID, loginResponse.data!.id.validate());
    await setValue(NAME, loginResponse.data!.name.validate());
    await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    await setValue(USER_TOKEN, loginResponse.data!.api_token.validate());
    await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contact_number.validate());
    await setValue(USER_PROFILE_PHOTO, loginResponse.data!.profile_image.validate());
    await setValue(USER_TYPE, loginResponse.data!.user_type.validate());
    await setValue(USER_NAME, loginResponse.data!.username.validate());
    await setValue(STATUS, loginResponse.data!.status.validate());

    /* await appStore.setUserName(loginResponse.userData!.username.validate());
    await appStore.setRole(loginResponse.userData!.user_type.validate());
    await appStore.setToken(loginResponse.userData!.api_token.validate());
    await appStore.setUserID(loginResponse.userData!.id.validate());*/
    await appStore.setUserEmail(loginResponse.data!.email.validate());
    await appStore.setLogin(true);

    await setValue(USER_PASSWORD, request['password']);

    return loginResponse;
  }).catchError((e) {
    throw e.toString();
  });
}

Future<void> logout(BuildContext context) async {
  await removeKey(USER_ID);
  await removeKey(NAME);
  await removeKey(USER_EMAIL);
  await removeKey(USER_TOKEN);
  await removeKey(USER_CONTACT_NUMBER);
  await removeKey(USER_PROFILE_PHOTO);
  await removeKey(USER_TYPE);
  await removeKey(USER_NAME);
  await removeKey(USER_PASSWORD);
  await removeKey(USER_ADDRESS);
  await removeKey(STATUS);

  await appStore.setLogin(false);

  LoginScreen().launch(context, isNewTask: true);
}

Future<ChangePasswordResponseModel> changePassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(await buildHttpResponse('change-password', request: req, method: HttpMethod.POST)));
}

Future<ChangePasswordResponseModel> forgotPassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(await buildHttpResponse('forgot-password', request: req, method: HttpMethod.POST)));
}

Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  multiPartRequest.headers.addAll(buildHeaderTokens());

  await multiPartRequest.send().then((res) {
    log(res.statusCode);
    res.stream.transform(utf8.decoder).listen((value) {
      log(value);
      onSuccess?.call(jsonDecode(value));
    });
  }).catchError((error) {
    onError?.call(error.toString());
  });
}

/// Profile Update
Future updateProfile({String? userName, String? name, String? userEmail, String? address, String? contactNumber, File? file}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
  multiPartRequest.fields['username'] = userName.validate();
  multiPartRequest.fields['email'] = userEmail ?? appStore.userEmail;
  multiPartRequest.fields['name'] = name.validate();
  multiPartRequest.fields['contact_number'] = contactNumber.validate();
  multiPartRequest.fields['address'] = address.validate();

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      LoginResponse res = LoginResponse.fromJson(data);

      await setValue(NAME, res.data!.name.validate());
      await setValue(USER_PROFILE_PHOTO, res.data!.profile_image.validate());
      await setValue(USER_NAME, res.data!.username.validate());
      await setValue(USER_ADDRESS, res.data!.address.validate());
      await setValue(USER_CONTACT_NUMBER, res.data!.contact_number.validate());
      await appStore.setUserEmail(res.data!.email.validate());
    }
  }, onError: (error) {
    toast(error.toString());
  });
}
