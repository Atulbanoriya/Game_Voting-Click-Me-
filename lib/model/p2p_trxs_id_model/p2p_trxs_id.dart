class PepTrxsId {
  Request? request;

  PepTrxsId({this.request});

  PepTrxsId.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? trxNo;
  String? image;
  String? description;
  int? fromUserId;
  int? toUserId;
  int? requestId;
  String? status;
  String? createdAt;
  String? updatedAt;

  String? name;
  String? upiqrcode;
  String? upiid;
  String? memberPhone;
  String? remark;


  Request(
      {
        this.id,
        this.trxNo,
        this.image,
        this.description,
        this.fromUserId,
        this.toUserId,
        this.requestId,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.memberPhone,
        this.upiid,
        this.upiqrcode,
        this.remark
      });

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trxNo = json['trx_no'];
    image = json['image'];
    description = json['description'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    requestId = json['request_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['name'];
    memberPhone = json['member_phone'];
    upiid = json['upiid'];
    upiqrcode = json['upiqrcode'];
    remark = json['remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['trx_no'] = this.trxNo;
    data['image'] = this.image;
    data['description'] = this.description;
    data['from_user_id'] = this.fromUserId;
    data['to_user_id'] = this.toUserId;
    data['request_id'] = this.requestId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name'] = this.name;
    data['member_phone'] = this.memberPhone;
    data['upiid'] = this.upiid;
    data['upiqrcode'] = this.upiqrcode;
    data['remark'] = this.remark;
    return data;
  }
}
