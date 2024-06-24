import 'dart:convert';

import 'PaginationModel.dart';

class CategoryModel {
  PaginationModel? pagination;
  List<Category>? data;

  CategoryModel({this.pagination, this.data});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <Category>[];
      json['data'].forEach((v) {
        data!.add(new Category.fromJson(v));
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
Category categoryfromJson(String str) => Category.fromJson(json.decode(str));

String categorytoJson(Category data) => json.encode(data.toJson());

class Category {
  int? id;
  String? name;
  int? storeId;
  String? storeName;
  int? storeownerId;
  dynamic storeowner;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<SubCategory>? subCategory;

  Category({
    this.id,
    this.name,
    this.storeId,
    this.storeName,
    this.storeownerId,
    this.storeowner,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.subCategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    storeId: json["store_id"],
    storeName: json["store_name"],
    storeownerId: json["storeowner_id"],
    storeowner: json["storeowner"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    subCategory: json["sub_category"] == null ? [] : List<SubCategory>.from(json["sub_category"]!.map((x) => SubCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "store_id": storeId,
    "store_name": storeName,
    "storeowner_id": storeownerId,
    "storeowner": storeowner,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "sub_category": subCategory == null ? [] : List<dynamic>.from(subCategory!.map((x) => x.toJson())),
  };
}

class SubCategory {
  int? id;
  int? categoryId;
  String? cateoryName;
  String? subcategoryName;
  int? status;
  int? storeId;
  String? storeName;
  DateTime? createdAt;
  DateTime? updatedAt;

  SubCategory({
    this.id,
    this.categoryId,
    this.cateoryName,
    this.subcategoryName,
    this.status,
    this.storeId,
    this.storeName,
    this.createdAt,
    this.updatedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["id"],
    categoryId: json["category_id"],
    cateoryName: json["cateory_name"],
    subcategoryName: json["subcategory_name"],
    status: json["status"],
    storeId: json["store_id"],
    storeName: json["store_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "cateory_name": cateoryName,
    "subcategory_name": subcategoryName,
    "status": status,
    "store_id": storeId,
    "store_name": storeName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}


