import 'dart:convert';

class User {
  final String name;
  final String cityName;
  final String pinCode;
  final String? sponsorId;
  final String userId;
  final String memberPhone;
  final String email;
  final String updatedAt;
  final String createdAt;
  final int id;
  final String ip;
  final String mac_id;

  User({
    required this.name,
    required this.cityName,
    required this.pinCode,
    this.sponsorId,
    required this.userId,
    required this.memberPhone,
    required this.email,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.ip,
    required this.mac_id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      cityName: json['city_name'],
      pinCode: json['pin_code'],
      sponsorId: json['sponsor_id'],
      userId: json['user_id'],
      memberPhone: json['member_phone'],
      email: json['email'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
      ip: json['ip'],
      mac_id: json['mac_id'],
    );
  }
}

class SignUpModel {
  final User user;

  SignUpModel({required this.user});

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        'name': user.name,
        'city_name': user.cityName,
        'pin_code': user.pinCode,
        'sponsor_id': user.sponsorId,
        'user_id': user.userId,
        'member_phone': user.memberPhone,
        'email': user.email,
        'updated_at': user.updatedAt,
        'created_at': user.createdAt,
        'id': user.id,
        'ip': user.ip,
        'mac_id': user.mac_id,
      },
    };
  }
}
