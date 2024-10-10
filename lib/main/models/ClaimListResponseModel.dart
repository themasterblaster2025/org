class ClaimListResponseModel {
  Pagination? pagination;
  List<ClaimItem>? data;

  ClaimListResponseModel({this.pagination, this.data});

  ClaimListResponseModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <ClaimItem>[];
      json['data'].forEach((v) {
        data!.add(new ClaimItem.fromJson(v));
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

  Pagination({this.totalItems, this.perPage, this.currentPage, this.totalPages});

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

class ClaimItem {
  int? id;
  int? clientId;
  String? clientName;
  String? trakingNo;
  String? profValue;
  String? detail;
  String? status;
  List<String>? attachmentFile;
  String? createdAt;
  String? updatedAt;

  ClaimItem(
      {this.id,
      this.clientId,
      this.clientName,
      this.trakingNo,
      this.profValue,
      this.detail,
      this.status,
      this.attachmentFile,
      this.createdAt,
      this.updatedAt});

  ClaimItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    trakingNo = json['traking_no'];
    profValue = json['prof_value'];
    detail = json['detail'];
    status = json['status'];
    attachmentFile = json['attachment_file'].cast<String>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['traking_no'] = this.trakingNo;
    data['prof_value'] = this.profValue;
    data['detail'] = this.detail;
    data['status'] = this.status;
    data['attachment_file'] = this.attachmentFile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
