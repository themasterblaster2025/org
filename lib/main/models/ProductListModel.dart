import 'PaginationModel.dart';

class ProductListModel {
  PaginationModel? pagination;
  List<ProductData>? data;

  ProductListModel({this.pagination, this.data});

  ProductListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <ProductData>[];
      json['data'].forEach((v) {
        data!.add(new ProductData.fromJson(v));
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

class ProductData {
  int? id;
  String? title;
  int? categoryId;
  int? subcategoryId;
  String? categoryName;
  String? subCategoryName;
  String? productImage;
  String? description;
  num? price;
  int? status;
  int? storeownerId;
  int? storeId;
  int? addedBy;
  int? storeDetailId;
  String? productType;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  int? totalRating;
  num? ratingAvg;
  int count = 0;

  ProductData({
    this.id,
    this.title,
    this.categoryId,
    this.subcategoryId,
    this.categoryName,
    this.subCategoryName,
    this.productImage,
    this.description,
    this.price,
    this.status,
    this.storeownerId,
    this.storeId,
    this.addedBy,
    this.storeDetailId,
    this.productType,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.totalRating,
    this.ratingAvg,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    categoryName = json['category_name'];
    subCategoryName = json['sub_category_name'];
    productImage = json['product_image'];
    description = json['description'];
    price = json['price'];
    status = json['status'];
    storeownerId = json['storeowner_id'];
    storeId = json['store_id'];
    addedBy = json['added_by'];
    storeDetailId = json['store_detail_id'];
    productType = json['product_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    totalRating = json['total_rating'];
    ratingAvg = json['rating_avg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['category_id'] = this.categoryId;
    data['subcategory_id'] = this.subcategoryId;
    data['category_name'] = this.categoryName;
    data['sub_category_name'] = this.subCategoryName;
    data['product_image'] = this.productImage;
    data['description'] = this.description;
    data['price'] = this.price;
    data['status'] = this.status;
    data['storeowner_id'] = this.storeownerId;
    data['store_id'] = this.storeId;
    data['added_by'] = this.addedBy;
    data['store_detail_id'] = this.storeDetailId;
    data['product_type'] = this.productType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['total_rating'] = this.totalRating;
    data['rating_avg'] = this.ratingAvg;
    return data;
  }
}