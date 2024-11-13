class ElectionCityModel {
  ElectedCandidates? electedCandidates;

  ElectionCityModel({this.electedCandidates});

  ElectionCityModel.fromJson(Map<String, dynamic> json) {
    electedCandidates = json['elected_candidates'] != null
        ? new ElectedCandidates.fromJson(json['elected_candidates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.electedCandidates != null) {
      data['elected_candidates'] = this.electedCandidates!.toJson();
    }
    return data;
  }
}

class ElectedCandidates {
  List<Group1>? group1;

  ElectedCandidates({this.group1});

  ElectedCandidates.fromJson(Map<String, dynamic> json) {
    if (json['group1'] != null) {
      group1 = <Group1>[];
      json['group1'].forEach((v) {
        group1!.add(new Group1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.group1 != null) {
      data['group1'] = this.group1!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Group1 {
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

  Group1(
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
        this.profileImage});

  Group1.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}