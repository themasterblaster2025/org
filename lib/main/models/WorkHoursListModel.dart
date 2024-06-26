import 'dart:convert';

import 'package:mighty_delivery/main/models/PaginationModel.dart';

class WorkHoursListModel {
  PaginationModel? pagination;
  List<WorkHoursData>? data;

  WorkHoursListModel({this.pagination, this.data});

  WorkHoursListModel.fromJson(Map<String, dynamic> json) {
    pagination =
        json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <WorkHoursData>[];
      json['data'].forEach((v) {
        data!.add(new WorkHoursData.fromJson(v));
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


class WorkHoursData {
  int? id;
  int? storeManagerId;
  int? storeDetailId;
  String? storeManagerName;
  String? day;
  int? storeOpenClose;
  String? startTime;
  String? endTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  WorkHoursData({
    this.id,
    this.storeManagerId,
    this.storeDetailId,
    this.storeManagerName,
    this.day,
    this.storeOpenClose,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkHoursData.fromJson(Map<String, dynamic> json) => WorkHoursData(
        id: json["id"],
        storeManagerId: json["store_manager_id"],
        storeDetailId: json["store_detail_id"],
        storeManagerName: json["store_manager_name"],
        day: json["day"],
        storeOpenClose: json["store-open/close"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "store_manager_id": storeManagerId,
        "store_detail_id": storeDetailId,
        "store_manager_name": storeManagerName,
        "day": day,
        "store-open/close": storeOpenClose,
        "start_time": startTime,
        "end_time": endTime,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
