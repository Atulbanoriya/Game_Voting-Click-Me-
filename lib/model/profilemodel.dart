// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  User user;

  Profile({
    required this.user,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
  };
}

class User {
  int id;
  String rankId;
  String subcriptionId;
  String countDirects;
  String name;
  String email;
  dynamic otp;
  dynamic firstName;
  dynamic lastName;
  String userId;
  dynamic userPassword;
  dynamic trnsPassword;
  dynamic title;
  dynamic stateName;
  dynamic cityName;
  dynamic profileImage;
  dynamic whatsappNo;
  String country;
  dynamic pinCode;
  dynamic gender;
  String sponsorId;
  dynamic spilId;
  dynamic levelSpil;
  dynamic leftRight;
  dynamic currentAddress;
  String member_phone;
  dynamic memberMobile;
  DateTime dateJoin;
  String panStatus;
  String status;
  DateTime lastLogin;
  dynamic loginIp;
  String blockSts;
  String smsSts;
  int typeId;
  DateTime emailVerifiedAt;
  dynamic holderName;
  dynamic bankName;
  dynamic accountNo;
  dynamic swiftIfscCode;
  dynamic branchName;
  String panCardNo;
  String aadhaarNo;
  dynamic phonepeNo;
  dynamic googlepayNo;
  dynamic paytmNo;
  dynamic panCard;
  dynamic aadhaarFront;
  dynamic aadhaarBack;
  dynamic chequePassbook;
  dynamic nomineeAadhaar;
  dynamic usdtWithdrawalWallet;
  dynamic usdtDepositWallet;
  String walletAmount;
  int totalIncome;
  DateTime createdAt;
  DateTime updatedAt;
  String selfBv;
  String teamBv;
  String directBv;
  String isPool;
  String upiid;
  String upiqrcode;

  User({
    required this.id,
    required this.rankId,
    required this.subcriptionId,
    required this.countDirects,
    required this.name,
    required this.email,
    required this.otp,
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userPassword,
    required this.trnsPassword,
    required this.title,
    required this.stateName,
    required this.cityName,
    required this.profileImage,
    required this.whatsappNo,
    required this.country,
    required this.pinCode,
    required this.gender,
    required this.sponsorId,
    required this.spilId,
    required this.levelSpil,
    required this.leftRight,
    required this.currentAddress,
    required this.member_phone,
    required this.memberMobile,
    required this.dateJoin,
    required this.panStatus,
    required this.status,
    required this.lastLogin,
    required this.loginIp,
    required this.blockSts,
    required this.smsSts,
    required this.typeId,
    required this.emailVerifiedAt,
    required this.holderName,
    required this.bankName,
    required this.accountNo,
    required this.swiftIfscCode,
    required this.branchName,
    required this.panCardNo,
    required this.aadhaarNo,
    required this.phonepeNo,
    required this.googlepayNo,
    required this.paytmNo,
    required this.panCard,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.chequePassbook,
    required this.nomineeAadhaar,
    required this.usdtWithdrawalWallet,
    required this.usdtDepositWallet,
    required this.walletAmount,
    required this.totalIncome,
    required this.createdAt,
    required this.updatedAt,
    required this.selfBv,
    required this.teamBv,
    required this.directBv,
    required this.isPool,
    required this.upiid,
    required this.upiqrcode,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    rankId: json["rank_id"],
    subcriptionId: json["subcription_id"],
    countDirects: json["count_directs"],
    name: json["name"],
    email: json["email"],
    otp: json["otp"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    userId: json["user_id"],
    userPassword: json["user_password"],
    trnsPassword: json["trns_password"],
    title: json["title"],
    stateName: json["state_name"],
    cityName: json["city_name"],
    profileImage: json["profile_image"],
    whatsappNo: json["whatsapp_no"],
    country: json["country"],
    pinCode: json["pin_code"],
    gender: json["gender"],
    sponsorId: json["sponsor_id"],
    spilId: json["spil_id"],
    levelSpil: json["level_spil"],
    leftRight: json["left_right"],
    currentAddress: json["current_address"],
    member_phone: json["member_phone"],
    memberMobile: json["member_mobile"],
    dateJoin: DateTime.parse(json["date_join"]),
    panStatus: json["pan_status"],
    status: json["status"],
    lastLogin: DateTime.parse(json["last_login"]),
    loginIp: json["login_ip"],
    blockSts: json["block_sts"],
    smsSts: json["sms_sts"],
    typeId: json["type_id"],
    emailVerifiedAt: DateTime.parse(json["email_verified_at"]),
    holderName: json["holder_name"],
    bankName: json["bank_name"],
    accountNo: json["account_no"],
    swiftIfscCode: json["swift_ifsc_code"],
    branchName: json["branch_name"],
    panCardNo: json["pan_card_no"],
    aadhaarNo: json["aadhaar_no"],
    phonepeNo: json["phonepe_no"],
    googlepayNo: json["googlepay_no"],
    paytmNo: json["paytm_no"],
    panCard: json["pan_card"],
    aadhaarFront: json["aadhaar_front"],
    aadhaarBack: json["aadhaar_back"],
    chequePassbook: json["cheque_passbook"],
    nomineeAadhaar: json["nominee_aadhaar"],
    usdtWithdrawalWallet: json["usdt_withdrawal_wallet"],
    usdtDepositWallet: json["usdt_deposit_wallet"],
    walletAmount: json["wallet_amount"],
    totalIncome: json["total_income"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    selfBv: json["self_bv"],
    teamBv: json["team_bv"],
    directBv: json["direct_bv"],
    isPool: json["is_pool"],
    upiid: json["upiid"],
    upiqrcode: json["upiqrcode"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rank_id": rankId,
    "subcription_id": subcriptionId,
    "count_directs": countDirects,
    "name": name,
    "email": email,
    "otp": otp,
    "first_name": firstName,
    "last_name": lastName,
    "user_id": userId,
    "user_password": userPassword,
    "trns_password": trnsPassword,
    "title": title,
    "state_name": stateName,
    "city_name": cityName,
    "profile_image": profileImage,
    "whatsapp_no": whatsappNo,
    "country": country,
    "pin_code": pinCode,
    "gender": gender,
    "sponsor_id": sponsorId,
    "spil_id": spilId,
    "level_spil": levelSpil,
    "left_right": leftRight,
    "current_address": currentAddress,
    "member_phone": member_phone,
    "member_mobile": memberMobile,
    "date_join": dateJoin.toIso8601String(),
    "pan_status": panStatus,
    "status": status,
    "last_login": lastLogin.toIso8601String(),
    "login_ip": loginIp,
    "block_sts": blockSts,
    "sms_sts": smsSts,
    "type_id": typeId,
    "email_verified_at": emailVerifiedAt.toIso8601String(),
    "holder_name": holderName,
    "bank_name": bankName,
    "account_no": accountNo,
    "swift_ifsc_code": swiftIfscCode,
    "branch_name": branchName,
    "pan_card_no": panCardNo,
    "aadhaar_no": aadhaarNo,
    "phonepe_no": phonepeNo,
    "googlepay_no": googlepayNo,
    "paytm_no": paytmNo,
    "pan_card": panCard,
    "aadhaar_front": aadhaarFront,
    "aadhaar_back": aadhaarBack,
    "cheque_passbook": chequePassbook,
    "nominee_aadhaar": nomineeAadhaar,
    "usdt_withdrawal_wallet": usdtWithdrawalWallet,
    "usdt_deposit_wallet": usdtDepositWallet,
    "wallet_amount": walletAmount,
    "total_income": totalIncome,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "self_bv": selfBv,
    "team_bv": teamBv,
    "direct_bv": directBv,
    "is_pool": isPool,
    "upiid": upiid,
    "upiqrcode": upiqrcode,
  };
}
