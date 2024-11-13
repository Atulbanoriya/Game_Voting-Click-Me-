class SliderElectionCity {
  List<ElectedCandidates>? electedCandidates;

  SliderElectionCity({this.electedCandidates});

  SliderElectionCity.fromJson(Map<String, dynamic> json) {
    if (json['elected_candidates'] != null) {
      electedCandidates = <ElectedCandidates>[];
      json['elected_candidates'].forEach((v) {
        electedCandidates!.add(new ElectedCandidates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.electedCandidates != null) {
      data['elected_candidates'] =
          this.electedCandidates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ElectedCandidates {
  int? id;
  int? userId;
  String? package;
  int? groupId;
  String? type;
  String? slotId;
  String? isWinner;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? userEmail;
  Null? profileImage;
  int? totalElec;
  int? totalElecWin;
  int? totalElecLoss;

  ElectedCandidates(
      {this.id,
        this.userId,
        this.package,
        this.groupId,
        this.type,
        this.slotId,
        this.isWinner,
        this.createdAt,
        this.updatedAt,
        this.userName,
        this.userEmail,
        this.profileImage,
        this.totalElec,
        this.totalElecWin,
        this.totalElecLoss});

  ElectedCandidates.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    package = json['package'];
    groupId = json['group_id'];
    type = json['type'];
    slotId = json['slot_id'];
    isWinner = json['is_winner'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    profileImage = json['profile_image'];
    totalElec = json['total_elec'];
    totalElecWin = json['total_elec_win'];
    totalElecLoss = json['total_elec_loss'];
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
    data['user_name'] = this.userName;
    data['user_email'] = this.userEmail;
    data['profile_image'] = this.profileImage;
    data['total_elec'] = this.totalElec;
    data['total_elec_win'] = this.totalElecWin;
    data['total_elec_loss'] = this.totalElecLoss;
    return data;
  }
}
