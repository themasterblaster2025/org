class VehicleModel {
  Pagination? pagination;
  List<VehicleData>? data;

  VehicleModel({this.pagination, this.data});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <VehicleData>[];
      json['data'].forEach((v) {
        data!.add(new VehicleData.fromJson(v));
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

class Pagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;

  Pagination(
      {this.totalItems, this.perPage, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    perPage = json['per_page'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_items'] = this.totalItems;
    data['per_page'] = this.perPage;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class VehicleData {
  int? id;
  String? title;
  String? type;
  String? size;
  String? capacity;
  List<String>? cityIds;
  CityText? cityText;
  int? status;
  String? description;
  String? vehicleImage;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;

  VehicleData(
      {this.id,
      this.title,
      this.type,
      this.size,
      this.capacity,
      this.cityIds,
      this.cityText,
      this.status,
      this.description,
      this.vehicleImage,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  VehicleData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    size = json['size'];
    capacity = json['capacity'];
    cityIds = json['city_ids'].cast<String>();
    cityText = json['city_text'] != null
        ? new CityText.fromJson(json['city_text'])
        : null;
    status = json['status'];
    description = json['description'];
    vehicleImage = json['vehicle_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['size'] = this.size;
    data['capacity'] = this.capacity;
    data['city_ids'] = this.cityIds;
    if (this.cityText != null) {
      data['city_text'] = this.cityText!.toJson();
    }
    data['status'] = this.status;
    data['description'] = this.description;
    data['vehicle_image'] = this.vehicleImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class CityText {
  String? s3;
  String? s2;
  String? s1;
  String? s4;

  CityText({this.s3, this.s2, this.s1, this.s4});

  CityText.fromJson(Map<String, dynamic> json) {
    s3 = json['3'];
    s2 = json['2'];
    s1 = json['1'];
    s4 = json['4'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['3'] = this.s3;
    data['2'] = this.s2;
    data['1'] = this.s1;
    data['4'] = this.s4;
    return data;
  }
}
