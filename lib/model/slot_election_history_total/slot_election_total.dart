class ElectionHistoryModel {
  int? id;
  String? name;
  String? type;
  String? appStartTime;
  String? appEndTime;
  String? electStartTime;
  String? electEndTime;
  String? createdAt;
  String? updatedAt;
  int? total;
  String? startDate;
  String? startTime;

  ElectionHistoryModel(
      {this.id,
        this.name,
        this.type,
        this.appStartTime,
        this.appEndTime,
        this.electStartTime,
        this.electEndTime,
        this.createdAt,
        this.updatedAt,
        this.total,
        this.startDate,
        this.startTime});

  ElectionHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    appStartTime = json['app_start_time'];
    appEndTime = json['app_end_time'];
    electStartTime = json['elect_start_time'];
    electEndTime = json['elect_end_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    total = json['total'];
    startDate = json['start_date'];
    startTime = json['start_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['app_start_time'] = this.appStartTime;
    data['app_end_time'] = this.appEndTime;
    data['elect_start_time'] = this.electStartTime;
    data['elect_end_time'] = this.electEndTime;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['total'] = this.total;
    data['start_date'] = this.startDate;
    data['start_time'] = this.startTime;
    return data;
  }
}
