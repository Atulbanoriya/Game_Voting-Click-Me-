class TrxsVerifyModel {
  final int trx_id;
  final String description;
  final int status;

  TrxsVerifyModel({required this.trx_id, required this.description, required this.status});

  factory TrxsVerifyModel.fromJson(Map<String, dynamic> json) {
    return TrxsVerifyModel(
      trx_id : json['trx_id'],
      description: json['description'],
      status: json['status'],
    );
  }
}