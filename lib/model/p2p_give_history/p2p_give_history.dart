class GiveSubmitHistory {
  List<Request>? request;

  GiveSubmitHistory({this.request});

  GiveSubmitHistory.fromJson(Map<String, dynamic> json) {
    if (json['Request'] != null) {
      request = <Request>[];
      json['Request'].forEach((v) {
        request!.add(new Request.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.request != null) {
      data['Request'] = this.request!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Request {
  int? id;
  int? trxId;
  String? trxNo;
  String? image;
  String? description;
  int? fromUserId;
  int? toUserId;
  int? requestId;
  int? status; // Change status type to int
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? userEmail;
  String? profileImage;
  String? memberPhone;

  Request(
      {this.id,
        this.trxId,
        this.trxNo,
        this.image,
        this.description,
        this.fromUserId,
        this.toUserId,
        this.requestId,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.userName,
        this.userEmail,
        this.profileImage,
        this.memberPhone});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trxId = json['trx_id'];
    trxNo = json['trx_no'];
    image = json['image'];
    description = json['description'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    requestId = json['request_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    profileImage = json['profile_image'];
    memberPhone = json['member_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['trx_id'] = this.trxId;
    data['trx_no'] = this.trxNo;
    data['image'] = this.image;
    data['description'] = this.description;
    data['from_user_id'] = this.fromUserId;
    data['to_user_id'] = this.toUserId;
    data['request_id'] = this.requestId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_name'] = this.userName;
    data['user_email'] = this.userEmail;
    data['profile_image'] = this.profileImage;
    data['member_phone'] = this.memberPhone;
    return data;
  }

  String getStatusText() {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}

