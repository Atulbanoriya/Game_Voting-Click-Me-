class WithdrawRequest {
  List<Request>? request;

  WithdrawRequest({this.request});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.request != null) {
      data['Request'] = this.request!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Request {
  int? userId;
  String? amount;
  String? type;
  int? number;

  Request({this.userId, this.amount, this.type});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    data['type'] = this.type;
    data['member_phone'] = this.type;
    return data;
  }
}