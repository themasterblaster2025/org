import 'dart:convert';

import 'package:mighty_delivery/main/models/LoginResponse.dart';

import 'OrderListModel.dart';
import 'ProductListModel.dart';

class OrderDetailModel {
  OrderData? data;
  Payment? payment;
  List<OrderHistory>? orderHistory;
  List<OrderItem>? orderItem;
  OrderRating? orderRating;

  UserData? clientDetail;
  UserData? deliveryManDetail;

  OrderDetailModel(
      {this.data,
      this.orderHistory,
      this.clientDetail,
      this.deliveryManDetail,
      this.orderItem,
      this.orderRating});

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new OrderData.fromJson(json['data']) : null;
    payment = json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    if (json['order_history'] != null) {
      orderHistory = <OrderHistory>[];
      json['order_history'].forEach((v) {
        orderHistory!.add(new OrderHistory.fromJson(v));
      });
    }
    if (json['order_item'] != null) {
      orderItem = <OrderItem>[];
      json['order_item'].forEach((v) {
        orderItem!.add(new OrderItem.fromJson(v));
      });
    }
    clientDetail =
        json['client_detail'] != null ? new UserData.fromJson(json['client_detail']) : null;
    deliveryManDetail = json['delivery_man_detail'] != null
        ? new UserData.fromJson(json['delivery_man_detail'])
        : null;
    orderRating =
        json["order_rating"] == null ? null : OrderRating.fromJson(json["order_rating"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    if (this.orderHistory != null) {
      data['order_history'] = this.orderHistory!.map((v) => v.toJson()).toList();
    }
    if (this.orderItem != null) {
      data['order_item'] = this.orderItem!.map((v) => v.toJson()).toList();
    }
    if (this.clientDetail != null) {
      data['client_detail'] = this.clientDetail!.toJson();
    }
    if (this.deliveryManDetail != null) {
      data['delivery_man_detail'] = this.deliveryManDetail!.toJson();
    }
    if (this.orderRating != null) {
      data["order_rating"] = orderRating?.toJson();
    }
    return data;
  }
}

class Payment {
  int? id;
  int? orderId;
  int? clientId;
  String? clientName;
  String? datetime;
  num? totalAmount;
  String? paymentType;
  String? txnId;
  String? paymentStatus;
  var transactionDetail;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  num? cancelCharges;
  num? adminCommission;
  String? receivedBy;
  num? deliveryManFee;
  num? deliveryManTip;
  num? deliveryManCommission;

  Payment(
      {this.id,
      this.orderId,
      this.clientId,
      this.clientName,
      this.datetime,
      this.totalAmount,
      this.paymentType,
      this.txnId,
      this.paymentStatus,
      this.transactionDetail,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.cancelCharges,
      this.adminCommission,
      this.receivedBy,
      this.deliveryManFee,
      this.deliveryManTip,
      this.deliveryManCommission});

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    datetime = json['datetime'];
    totalAmount = json['total_amount'];
    paymentType = json['payment_type'];
    txnId = json['txn_id'];
    paymentStatus = json['payment_status'];
    transactionDetail = json['transaction_detail'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    cancelCharges = json['cancel_charges'];
    adminCommission = json['admin_commission'];
    receivedBy = json['received_by'];
    deliveryManFee = json['delivery_man_fee'];
    deliveryManTip = json['delivery_man_tip'];
    deliveryManCommission = json['delivery_man_commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['datetime'] = this.datetime;
    data['total_amount'] = this.totalAmount;
    data['payment_type'] = this.paymentType;
    data['txn_id'] = this.txnId;
    data['payment_status'] = this.paymentStatus;
    data['transaction_detail'] = this.transactionDetail;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['cancel_charges'] = this.cancelCharges;
    data['admin_commission'] = this.adminCommission;
    data['received_by'] = this.receivedBy;
    data['delivery_man_fee'] = this.deliveryManFee;
    data['delivery_man_tip'] = this.deliveryManTip;
    data['delivery_man_commission'] = this.deliveryManCommission;
    return data;
  }
}

class OrderHistory {
  int? id;
  int? orderId;
  String? datetime;
  String? historyType;
  String? historyMessage;
  HistoryData? historyData;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  OrderHistory(
      {this.id,
      this.orderId,
      this.datetime,
      this.historyType,
      this.historyMessage,
      this.historyData,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    datetime = json['datetime'];
    historyType = json['history_type'];
    historyMessage = json['history_message'];
    historyData =
        json['history_data'] != null ? new HistoryData.fromJson(json['history_data']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['datetime'] = this.datetime;
    data['history_type'] = this.historyType;
    data['history_message'] = this.historyMessage;
    if (this.historyData != null) {
      data['history_data'] = this.historyData!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class HistoryData {
  var clientId;
  String? clientName;
  var deliveryManId;
  String? deliveryManName;
  var orderId;
  String? paymentStatus;

  HistoryData({this.clientId, this.clientName, this.deliveryManName});

  HistoryData.fromJson(Map<String, dynamic> json) {
    clientId = json['client_id'];
    clientName = json['client_name'];
    deliveryManId = json['delivery_man_id'];
    deliveryManName = json['delivery_man_name'];
    orderId = json['order_id'];
    paymentStatus = json['payment_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['delivery_man_id'] = this.deliveryManId;
    data['delivery_man_name'] = this.deliveryManName;
    data['order_id'] = this.orderId;
    data['payment_status'] = this.paymentStatus;
    return data;
  }
}

OrderItem orderItemfromJson(String str) => OrderItem.fromJson(json.decode(str));

String orderItemtoJson(OrderItem data) => json.encode(data.toJson());

class OrderItem {
  int? id;
  int? orderId;
  int? productId;
  int? amount;
  int? totalAmount;
  int? quantity;
  List<ProductData>? productData;

  OrderItem({
    this.id,
    this.orderId,
    this.productId,
    this.amount,
    this.totalAmount,
    this.quantity,
    this.productData,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["order_id"],
        productId: json["product_id"],
        amount: json["amount"],
        totalAmount: json["total_amount"],
        quantity: json["quantity"],
        productData: json["product_data"] == null
            ? []
            : List<ProductData>.from(
                json["product_data"]!.map((x) => ProductData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "product_id": productId,
        "amount": amount,
        "total_amount": totalAmount,
        "quantity": quantity,
        "product_data":
            productData == null ? [] : List<dynamic>.from(productData!.map((x) => x.toJson())),
      };
}

OrderRating orderRatingfromJson(String str) => OrderRating.fromJson(json.decode(str));

String orderRatingtoJson(OrderRating data) => json.encode(data.toJson());



class OrderRating {
  int? id;
  int? storeDetailId;
  int? userId;
  int? orderId;
  num? rating;
  String? review;
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderRating({
    this.id,
    this.storeDetailId,
    this.userId,
    this.orderId,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderRating.fromJson(Map<String, dynamic> json) => OrderRating(
        id: json["id"],
        storeDetailId: json["store_detail_id"],
        userId: json["user_id"],
        orderId: json["order_id"],
        rating: json["rating"],
        review: json["review"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "store_detail_id": storeDetailId,
        "user_id": userId,
        "order_id": orderId,
        "rating": rating,
        "review": review,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
