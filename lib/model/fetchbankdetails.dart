class FetchBankDetails {
  String? upiId;
  String? qrcodeUrl;

  FetchBankDetails({this.upiId, this.qrcodeUrl});

  FetchBankDetails.fromJson(Map<String, dynamic> json) {
    upiId = json['upiId'];
    qrcodeUrl = json['qrcodeUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upiId'] = this.upiId;
    data['qrcodeUrl'] = this.qrcodeUrl;
    return data;
  }
}
