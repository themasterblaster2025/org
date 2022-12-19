
import 'PaginationModel.dart';

class WithDrawListModel {
  List<WithDrawModel>? data;
  PaginationModel? pagination;
  WalletBalance? wallet_balance;

  WithDrawListModel({this.data, this.pagination, this.wallet_balance});

  factory WithDrawListModel.fromJson(Map<String, dynamic> json) {
    return WithDrawListModel(
      data: json['data'] != null ? (json['data'] as List).map((i) => WithDrawModel.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null,
      wallet_balance: json['wallet_data'] != null ? WalletBalance.fromJson(json['wallet_data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.wallet_balance != null) {
      data['wallet_data'] = this.wallet_balance!.toJson();
    }
    return data;
  }
}

class WithDrawModel {
  int? id;
  int? userId;
  String? userName;
  int? amount;
  String? currency;
  String? status;
  String? createdAt;
  String? updatedAt;

  WithDrawModel(
      {this.id,
        this.userId,
        this.userName,
        this.amount,
        this.currency,
        this.status,
        this.createdAt,
        this.updatedAt});

  WithDrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
class WalletBalance {
  int? id;
  int? userId;
  int? totalAmount;
  int? onlineReceived;
  int? collectedCash;
  int? manualReceived;
  int? totalWithdrawn;
  String? currency;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  WalletBalance(
      {this.id,
        this.userId,
        this.totalAmount,
        this.onlineReceived,
        this.collectedCash,
        this.manualReceived,
        this.totalWithdrawn,
        this.currency,
        this.createdAt,
        this.updatedAt,
        this.deletedAt});

  WalletBalance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    totalAmount = json['total_amount'];
    onlineReceived = json['online_received'];
    collectedCash = json['collected_cash'];
    manualReceived = json['manual_received'];
    totalWithdrawn = json['total_withdrawn'];
    currency = json['currency'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['total_amount'] = this.totalAmount;
    data['online_received'] = this.onlineReceived;
    data['collected_cash'] = this.collectedCash;
    data['manual_received'] = this.manualReceived;
    data['total_withdrawn'] = this.totalWithdrawn;
    data['currency'] = this.currency;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
