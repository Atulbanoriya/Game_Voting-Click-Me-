class tranctionsHistory {
  List<Transactions>? transactions;

  tranctionsHistory({this.transactions});

  tranctionsHistory.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(new Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  int? id;
  String? transRefNo;
  String? memberId;
  Null? toMemberId;
  Null? walletId;
  String? trnsType;
  String? trnsAmount;
  int? isActive;
  String? trnsRemark;
  String? trnsFor;
  String? trnsDate;
  Null? txHash;
  Null? createdAt;
  Null? updatedAt;

  Transactions(
      {this.id,
        this.transRefNo,
        this.memberId,
        this.toMemberId,
        this.walletId,
        this.trnsType,
        this.trnsAmount,
        this.isActive,
        this.trnsRemark,
        this.trnsFor,
        this.trnsDate,
        this.txHash,
        this.createdAt,
        this.updatedAt});

  Transactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transRefNo = json['trans_ref_no'];
    memberId = json['member_id'];
    toMemberId = json['to_member_id'];
    walletId = json['wallet_id'];
    trnsType = json['trns_type'];
    trnsAmount = json['trns_amount'];
    isActive = json['isActive'];
    trnsRemark = json['trns_remark'];
    trnsFor = json['trns_for'];
    trnsDate = json['trns_date'];
    txHash = json['txHash'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['trans_ref_no'] = this.transRefNo;
    data['member_id'] = this.memberId;
    data['to_member_id'] = this.toMemberId;
    data['wallet_id'] = this.walletId;
    data['trns_type'] = this.trnsType;
    data['trns_amount'] = this.trnsAmount;
    data['isActive'] = this.isActive;
    data['trns_remark'] = this.trnsRemark;
    data['trns_for'] = this.trnsFor;
    data['trns_date'] = this.trnsDate;
    data['txHash'] = this.txHash;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
