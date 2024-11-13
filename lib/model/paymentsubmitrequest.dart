class SubmitPayment {
  Request? request;

  SubmitPayment({this.request});

  SubmitPayment.fromJson(Map<String, dynamic> json) {
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
  String? trxNo;
  Null? image;
  String? fromUserId;
  String? toUserId;
  String? requestId;
  String? status;
  String? description;
  String? updatedAt;
  String? createdAt;
  int? id;

  Request(
      {this.trxNo,
        this.image,
        this.fromUserId,
        this.toUserId,
        this.requestId,
        this.status,
        this.description,
        this.updatedAt,
        this.createdAt,
        this.id});

  Request.fromJson(Map<String, dynamic> json) {
    trxNo = json['trx_no'];
    image = json['image'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    requestId = json['request_id'];
    status = json['status'];
    description = json['description'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trx_no'] = this.trxNo;
    data['image'] = this.image;
    data['from_user_id'] = this.fromUserId;
    data['to_user_id'] = this.toUserId;
    data['request_id'] = this.requestId;
    data['status'] = this.status;
    data['description'] = this.description;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
