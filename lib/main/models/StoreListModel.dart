import 'package:mighty_delivery/main/models/PaginationModel.dart';
import 'package:mighty_delivery/main/models/RatingListModel.dart';

class StoreListModel {
  PaginationModel? pagination;
  List<StoreData>? data;

  StoreListModel({this.pagination, this.data});

  StoreListModel.fromJson(Map<String, dynamic> json) {
    pagination =
        json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <StoreData>[];
      json['data'].forEach((v) {
        data!.add(new StoreData.fromJson(v));
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

class StoreData {
  int? id;
  int? storeManagerId;
  String? storeManagerName;
  String? storeName;
  String? contactNumber;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? address;
  String? latitude;
  String? longitude;
  String? description;
  String? storeImage;
  int? isFavourite;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<dynamic>? productData;
  List<Rating>? rating;
  num? averageRating;
  WorkingHours? workingHours;

  StoreData({
    this.id,
    this.storeManagerId,
    this.storeManagerName,
    this.storeName,
    this.contactNumber,
    this.countryId,
    this.countryName,
    this.cityId,
    this.cityName,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.storeImage,
    this.isFavourite,
    this.createdAt,
    this.updatedAt,
    this.productData,
    this.rating,
    this.averageRating,
    this.workingHours,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) => StoreData(
        id: json["id"],
        storeManagerId: json["storeowner_id"],
        storeManagerName: json["storeowner_name"],
        storeName: json["store_name"],
        contactNumber: json["contact_number"],
        countryId: json["country_id"],
        countryName: json["country_name"],
        cityId: json["city_id"],
        cityName: json["city_name"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        description: json["description"],
        storeImage: json["store_image"],
        isFavourite: json["is_favourite"],
        averageRating: json["average_rating"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        productData: json["product_data"] == null
            ? []
            : List<dynamic>.from(json["product_data"]!.map((x) => x)),
        rating: json["rating"] == null
            ? []
            : List<Rating>.from(json["rating"]!.map((x) => Rating.fromJson(x))),
        workingHours:
            json["workingHours"] == null ? null : WorkingHours.fromJson(json["workingHours"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeowner_id": storeManagerId,
        "storeowner_name": storeManagerName,
        "store_name": storeName,
        "contact_number": contactNumber,
        "country_id": countryId,
        "country_name": countryName,
        "city_id": cityId,
        "city_name": cityName,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "description": description,
        "store_image": storeImage,
        "is_favourite": isFavourite,
        "average_rating": averageRating,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "product_data":
            productData == null ? [] : List<dynamic>.from(productData!.map((x) => x)),
        "rating": rating == null ? [] : List<Rating>.from(rating!.map((x) => x.toJson())),
        "workingHours": workingHours == null ? null : workingHours!.toJson(),
      };
}

class WorkingHours {
  String? day;
  String? end;
  String? start;
  bool? isOpen;

  WorkingHours({this.day, this.end, this.start, this.isOpen});

  WorkingHours.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    end = json['end'];
    start = json['start'];
    isOpen = json['is_open'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['end'] = this.end;
    data['start'] = this.start;
    data['is_open'] = this.isOpen;
    return data;
  }
}
