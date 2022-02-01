class LoginResponse {
  UserData? data;
  String? message;

  LoginResponse({this.data, this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      message: json['message'],
    );
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

class UserData {
  String? api_token;
  String? contact_number;
  String? created_at;
  String? email;
  int? id;
  String? name;
  String? profile_photo_url;
  String? updated_at;
  String? user_type;
  String? username;
  String? address;

  UserData({
    this.api_token,
    this.contact_number,
    this.created_at,
    this.email,
    this.id,
    this.name,
    this.profile_photo_url,
    this.updated_at,
    this.user_type,
    this.username,
    this.address,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      api_token: json['api_token'],
      contact_number: json['contact_number'],
      created_at: json['created_at'],
      email: json['email'],
      id: json['id'],
      name: json['name'],
      profile_photo_url: json['profile_photo_url'],
      updated_at: json['updated_at'],
      user_type: json['user_type'],
      username: json['username'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['api_token'] = this.api_token;
    data['contact_number'] = this.contact_number;
    data['created_at'] = this.created_at;
    data['email'] = this.email;
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile_photo_url'] = this.profile_photo_url;
    data['updated_at'] = this.updated_at;
    data['user_type'] = this.user_type;
    data['username'] = this.username;
    data['address'] = this.address;
    return data;
  }
}
