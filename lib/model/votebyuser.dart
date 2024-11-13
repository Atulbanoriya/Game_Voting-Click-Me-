// To parse this JSON data, do
//
//     final votevote = votevoteFromJson(jsonString);

import 'dart:convert';

Votevote votevoteFromJson(String str) => Votevote.fromJson(json.decode(str));

String votevoteToJson(Votevote data) => json.encode(data.toJson());

class Votevote {
  Voter voter;

  Votevote({
    required this.voter,
  });

  factory Votevote.fromJson(Map<String, dynamic> json) => Votevote(
    voter: Voter.fromJson(json["voter"]),
  );

  Map<String, dynamic> toJson() => {
    "voter": voter.toJson(),
  };
}

class Voter {
  int voterId;
  int candidateId;
  String type;
  int package;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Voter({
    required this.voterId,
    required this.candidateId,
    required this.type,
    required this.package,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Voter.fromJson(Map<String, dynamic> json) => Voter(
    voterId: json["voter_id"],
    candidateId: json["candidate_id"],
    type: json["type"],
    package: json["package"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "voter_id": voterId,
    "candidate_id": candidateId,
    "type": type,
    "package": package,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}
