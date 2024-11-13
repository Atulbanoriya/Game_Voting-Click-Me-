class VerifyPaymentApprovel {
  Request? request;

  VerifyPaymentApprovel({this.request});

  VerifyPaymentApprovel.fromJson(Map<String, dynamic> json) {
    request =
    json['Request'] != null ? new Request.fromJson(json['Request']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.request != null) {
      data['Request'] = this.request!.toJson();
    }
    return data;
  }
}

class Request {
  int? trxId;
  String? trxNo;
  Null? image;
  String? description;
  int? fromUserId;
  int? toUserId;
  int? requestId;
  String? status;
  String? updatedAt;
  String? createdAt;
  int? id;

  Request(
      {this.trxId,
        this.trxNo,
        this.image,
        this.description,
        this.fromUserId,
        this.toUserId,
        this.requestId,
        this.status,
        this.updatedAt,
        this.createdAt,
        this.id});

  Request.fromJson(Map<String, dynamic> json) {
    trxId = json['trx_id'];
    trxNo = json['trx_no'];
    image = json['image'];
    description = json['description'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    requestId = json['request_id'];
    status = json['status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trx_id'] = this.trxId;
    data['trx_no'] = this.trxNo;
    data['image'] = this.image;
    data['description'] = this.description;
    data['from_user_id'] = this.fromUserId;
    data['to_user_id'] = this.toUserId;
    data['request_id'] = this.requestId;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
