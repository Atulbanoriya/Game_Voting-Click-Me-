// To parse this JSON data, do
//
//     final applyCandidate = applyCandidateFromJson(jsonString);

import 'dart:convert';

ApplyCandidate applyCandidateFromJson(String str) => ApplyCandidate.fromJson(json.decode(str));

String applyCandidateToJson(ApplyCandidate data) => json.encode(data.toJson());

class ApplyCandidate {
  String message;
  Candidate candidate;

  ApplyCandidate({
    required this.message,
    required this.candidate,
  });

  factory ApplyCandidate.fromJson(Map<String, dynamic> json) => ApplyCandidate(
    message: json["message"],
    candidate: Candidate.fromJson(json["Candidate"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "Candidate": candidate.toJson(),
  };
}

class Candidate {
  int userId;
  String type;
  String package;
  String slotId;
  int groupId;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Candidate({
    required this.userId,
    required this.type,
    required this.package,
    required this.slotId,
    required this.groupId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    userId: json["user_id"],
    type: json["type"],
    package: json["package"],
    slotId: json["slot_id"],
    groupId: json["group_id"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "type": type,
    "package": package,
    "slot_id": slotId,
    "group_id": groupId,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}
