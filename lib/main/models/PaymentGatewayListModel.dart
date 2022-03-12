import 'PaginationModel.dart';

class PaymentGatewayListModel {
  PaginationModel? pagination;
  List<PaymentGatewayData>? data;

  PaymentGatewayListModel({this.pagination, this.data});

  PaymentGatewayListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new PaginationModel.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <PaymentGatewayData>[];
      json['data'].forEach((v) {
        data!.add(new PaymentGatewayData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentGatewayData {
  int? id;
  String? title;
  String? type;
  int? status;
  int? isTest;
  TestValue? testValue;
  TestValue? liveValue;
  String? gatewayLogo;
  String? createdAt;
  String? updatedAt;

  PaymentGatewayData(
      {this.id,
        this.title,
        this.type,
        this.status,
        this.isTest,
        this.testValue,
        this.liveValue,
        this.gatewayLogo,
        this.createdAt,
        this.updatedAt});

  PaymentGatewayData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    status = json['status'];
    isTest = json['is_test'];
    testValue = json['test_value'] != null
        ? new TestValue.fromJson(json['test_value'])
        : null;
    liveValue = json['live_value'] != null
        ? new TestValue.fromJson(json['live_value'])
        : null;
    gatewayLogo = json['gateway_logo'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['status'] = this.status;
    data['is_test'] = this.isTest;
    if (this.testValue != null) {
      data['test_value'] = this.testValue!.toJson();
    }
    if (this.liveValue != null) {
      data['live_value'] = this.liveValue!.toJson();
    }
    data['gateway_logo'] = this.gatewayLogo;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class TestValue {
  String? publicKey;
  String? secretKey;
  String? encryptionKey;
  String? keyId;
  String? secretId;
  String? publishableKey;

  TestValue(
      {this.publicKey,
        this.secretKey,
        this.encryptionKey,
        this.keyId,
        this.secretId,
        this.publishableKey});

  TestValue.fromJson(Map<String, dynamic> json) {
    publicKey = json['public_key'];
    secretKey = json['secret_key'];
    encryptionKey = json['encryption_key'];
    keyId = json['key_id'];
    secretId = json['secret_id'];
    publishableKey = json['publishable_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['public_key'] = this.publicKey;
    data['secret_key'] = this.secretKey;
    data['encryption_key'] = this.encryptionKey;
    data['key_id'] = this.keyId;
    data['secret_id'] = this.secretId;
    data['publishable_key'] = this.publishableKey;
    return data;
  }
}
