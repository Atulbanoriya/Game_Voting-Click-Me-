class StateHistoryApply {
  List<TotalApply>? totalApply;

  StateHistoryApply({this.totalApply});

  StateHistoryApply.fromJson(Map<String, dynamic> json) {
    if (json['total_apply'] != null) {
      totalApply = <TotalApply>[];
      json['total_apply'].forEach((v) {
        totalApply!.add(new TotalApply.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.totalApply != null) {
      data['total_apply'] = this.totalApply!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TotalApply {
  int? id;
  int? userId;
  String? package;
  int? groupId;
  String? type;
  String? slotId;
  String? isWinner;
  String? createdAt;
  String? updatedAt;

  String? electstarttime;

  String? winnerName;

  TotalApply({
        this.id,
        this.userId,
        this.package,
        this.groupId,
        this.type,
        this.slotId,
        this.isWinner,
        this.createdAt,
        this.updatedAt,
        this.electstarttime,
        this.winnerName
      });

  TotalApply.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    package = json['package'];
    groupId = json['group_id'];
    type = json['type'];
    slotId = json['slot_id'];
    isWinner = json['is_winner'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    electstarttime = json['elect_start_time'];
    winnerName = json['winner_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['package'] = this.package;
    data['group_id'] = this.groupId;
    data['type'] = this.type;
    data['slot_id'] = this.slotId;
    data['is_winner'] = this.isWinner;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['elect_start_time'] = this.electstarttime;
    data['winner_name'] = this.winnerName;
    return data;
  }
}
