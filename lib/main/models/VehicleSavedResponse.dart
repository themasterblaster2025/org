import 'DeliverymanVehicleListModel.dart';

class VehicleSavedResponse {
  String? message;
  DeliverymanVehicle? data;

  VehicleSavedResponse({this.message, this.data});

  VehicleSavedResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new DeliverymanVehicle.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

// class Data {
//   int? id;
//   int? deliveryManId;
//   String? deliveryMan;
//   String? startDatetime;
//   String? endDatetime;
//   int? isActive;
//   VehicleInfo? vehicleInfo;
//
//   Data(
//       {this.id,
//       this.deliveryManId,
//       this.deliveryMan,
//       this.startDatetime,
//       this.endDatetime,
//       this.isActive,
//       this.vehicleInfo});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     deliveryManId = json['delivery_man_id'];
//     deliveryMan = json['delivery_man'];
//     startDatetime = json['start_datetime'];
//     endDatetime = json['end_datetime'];
//     isActive = json['is_active'];
//     vehicleInfo = json['vehicle_info'] != null ? new VehicleInfo.fromJson(json['vehicle_info']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['delivery_man_id'] = this.deliveryManId;
//     data['delivery_man'] = this.deliveryMan;
//     data['start_datetime'] = this.startDatetime;
//     data['end_datetime'] = this.endDatetime;
//     data['is_active'] = this.isActive;
//     if (this.vehicleInfo != null) {
//       data['vehicle_info'] = this.vehicleInfo!.toJson();
//     }
//     return data;
//   }
// }
//
// class VehicleInfo {
//   String? make;
//   String? model;
//   String? color;
//   String? yearOfManufacture;
//   String? vehicleIdentificationNumber;
//   String? licensePlateNumber;
//   String? currentMileage;
//   String? fuelType;
//   String? transmissionType;
//   String? ownerName;
//   String? address;
//   String? registrationDate;
//   String? ownerNumber;
//   String? vehicleId;
//
//   VehicleInfo(
//       {this.make,
//       this.model,
//       this.color,
//       this.yearOfManufacture,
//       this.vehicleIdentificationNumber,
//       this.licensePlateNumber,
//       this.currentMileage,
//       this.fuelType,
//       this.transmissionType,
//       this.ownerName,
//       this.address,
//       this.registrationDate,
//       this.ownerNumber,
//       this.vehicleId});
//
//   VehicleInfo.fromJson(Map<String, dynamic> json) {
//     make = json['make'];
//     model = json['model'];
//     color = json['color'];
//     yearOfManufacture = json['year_of_manufacture'];
//     vehicleIdentificationNumber = json['vehicle_identification_number'];
//     licensePlateNumber = json['license_plate_number'];
//     currentMileage = json['current_mileage'];
//     fuelType = json['fuel_type'];
//     transmissionType = json['transmission_type'];
//     ownerName = json['owner_name'];
//     address = json['address'];
//     registrationDate = json['registration_date'];
//     ownerNumber = json['owner_number'];
//     vehicleId = json['vehicle_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['make'] = this.make;
//     data['model'] = this.model;
//     data['color'] = this.color;
//     data['year_of_manufacture'] = this.yearOfManufacture;
//     data['vehicle_identification_number'] = this.vehicleIdentificationNumber;
//     data['license_plate_number'] = this.licensePlateNumber;
//     data['current_mileage'] = this.currentMileage;
//     data['fuel_type'] = this.fuelType;
//     data['transmission_type'] = this.transmissionType;
//     data['owner_name'] = this.ownerName;
//     data['address'] = this.address;
//     data['registration_date'] = this.registrationDate;
//     data['owner_number'] = this.ownerNumber;
//     data['vehicle_id'] = this.vehicleId;
//     return data;
//   }
// }
