class trnxsGetModel {
  List<Collection>? collection;

  trnxsGetModel({this.collection});

  trnxsGetModel.fromJson(Map<String, dynamic> json) {
    if (json['Collection'] != null) {
      collection = <Collection>[];
      json['Collection'].forEach((v) {
        collection!.add(new Collection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.collection != null) {
      data['Collection'] = this.collection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Collection {
  final int id;
  final String trxNo;
  final String? image;
  final String description;
  final int fromUserId;
  final int toUserId;
  final int requestId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String userName;
  final String userEmail;
  final String? profileImage;
  final String memberPhone;

  Collection({
    required this.id,
    required this.trxNo,
    this.image,
    required this.description,
    required this.fromUserId,
    required this.toUserId,
    required this.requestId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userEmail,
    this.profileImage,
    required this.memberPhone,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      trxNo: json['trx_no'],
      image: json['image'],
      description: json['description'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      requestId: json['request_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      profileImage: json['profile_image'],
      memberPhone: json['member_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['trx_no'] = trxNo;
    data['image'] = image;
    data['description'] = description;
    data['from_user_id'] = fromUserId;
    data['to_user_id'] = toUserId;
    data['request_id'] = requestId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['profile_image'] = profileImage;
    data['member_phone'] = memberPhone;
    return data;
  }
}

