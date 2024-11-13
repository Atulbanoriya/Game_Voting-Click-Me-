class TakeRequestHistory {
  int? id;
  int? userId;
  String? amount;
  String? type;
  String? cronStatus;
  String? cronStatusDatetime;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? upiqrcode;
  String? upiid;
  String? memberPhone;

  TakeRequestHistory(
      {this.id,
        this.userId,
        this.amount,
        this.type,
        this.cronStatus,
        this.cronStatusDatetime,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.upiqrcode,
        this.upiid,
        this.memberPhone});

  TakeRequestHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    amount = json['amount'];
    type = json['type'];
    cronStatus = json['cron_status'];
    cronStatusDatetime = json['cron_status_datetime'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['name'];
    upiqrcode = json['upiqrcode'];
    upiid = json['upiid'];
    memberPhone = json['member_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    data['type'] = this.type;
    data['cron_status'] = this.cronStatus;
    data['cron_status_datetime'] = this.cronStatusDatetime;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name'] = this.name;
    data['upiqrcode'] = this.upiqrcode;
    data['upiid'] = this.upiid;
    data['member_phone'] = this.memberPhone;
    return data;
  }
}
