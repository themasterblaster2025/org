import 'package:mighty_delivery/main/models/PaginationModel.dart';

class CityListModel {
  List<CityModel>? data;
  PaginationModel? pagination;

  CityListModel({this.data, this.pagination});

  factory CityListModel.fromJson(Map<String, dynamic> json) {
    return CityListModel(
      data: json['data'] != null ? (json['data'] as List).map((i) => CityModel.fromJson(i)).toList() : null,
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

class CityModel {
  String? address;
  int? cancel_charges;
  int? country_id;
  String? country_name;
  String? created_at;
  String? deleted_at;

  //List<Object>? extra_charges;
  int? fixed_charges;
  int? id;
  int? min_distance;
  int? min_weight;
  String? name;
  int? per_distance_charges;
  int? per_weight_charges;
  int? status;
  String? updated_at;

  CityModel({
    this.address,
    this.cancel_charges,
    this.country_id,
    this.country_name,
    this.created_at,
    this.deleted_at,
    //this.extra_charges,
    this.fixed_charges,
    this.id,
    this.min_distance,
    this.min_weight,
    this.name,
    this.per_distance_charges,
    this.per_weight_charges,
    this.status,
    this.updated_at,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      address: json['address'],
      cancel_charges: json['cancel_charges'],
      country_id: json['country_id'],
      country_name: json['country_name'],
      created_at: json['created_at'],
      deleted_at: json['deleted_at'],
      //extra_charges: json['extra_charges'] != null ? (json['extra_charges'] as List).map((i) => Object.fromJson(i)).toList() : null,
      fixed_charges: json['fixed_charges'],
      id: json['id'],
      min_distance: json['min_distance'],
      min_weight: json['min_weight'],
      name: json['name'],
      per_distance_charges: json['per_distance_charges'],
      per_weight_charges: json['per_weight_charges'],
      status: json['status'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['cancel_charges'] = this.cancel_charges;
    data['country_id'] = this.country_id;
    data['country_name'] = this.country_name;
    data['created_at'] = this.created_at;
    data['deleted_at'] = this.deleted_at;
    data['fixed_charges'] = this.fixed_charges;
    data['id'] = this.id;
    data['min_distance'] = this.min_distance;
    data['min_weight'] = this.min_weight;
    data['name'] = this.name;
    data['per_distance_charges'] = this.per_distance_charges;
    data['per_weight_charges'] = this.per_weight_charges;
    data['status'] = this.status;
    data['updated_at'] = this.updated_at;
    /* if (this.extra_charges != null) {
      data['extra_charges'] = this.extra_charges.map((v) => v.toJson()).toList();
    }*/
    return data;
  }
}
