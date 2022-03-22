import 'package:mighty_delivery/main/models/PaginationModel.dart';

class CountryListModel {
  List<CountryModel>? data;
  PaginationModel? pagination;

  CountryListModel({this.data, this.pagination});

  factory CountryListModel.fromJson(Map<String, dynamic> json) {
    return CountryListModel(
      data: json['data'] != null ? (json['data'] as List).map((i) => CountryModel.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null,
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
    return data;
  }
}

class CountryModel {
  String? created_at;
  String? deleted_at;
  String? distance_type;
  int? id;
  var links;
  String? name;
  int? status;
  String? updated_at;
  String? weight_type;

  CountryModel({
    this.created_at,
    this.deleted_at,
    this.distance_type,
    this.id,
    this.links,
    this.name,
    this.status,
    this.updated_at,
    this.weight_type,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      created_at: json['created_at'],
      deleted_at: json['deleted_at'],
      distance_type: json['distance_type'],
      id: json['id'],
      links: json['links'],
      name: json['name'],
      status: json['status'],
      updated_at: json['updated_at'],
      weight_type: json['weight_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.created_at;
    data['deleted_at'] = this.deleted_at;
    data['distance_type'] = this.distance_type;
    data['id'] = this.id;
    data['links'] = this.links;
    data['name'] = this.name;
    data['status'] = this.status;
    data['updated_at'] = this.updated_at;
    data['weight_type'] = this.weight_type;
    return data;
  }
}
