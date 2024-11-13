class Candidate {
  final int id;
  final int groupId;
  final String userName;
  final String? profileImage;
  final String type;
  bool hasVoted;

  Candidate({
    required this.id,
    required this.groupId,
    required this.userName,
    this.profileImage,
    required this.type,
    this.hasVoted = false,
  });

  factory Candidate.fromJson(Map<String, dynamic> json, String type) {
    return Candidate(
      id: json['id'],
      groupId: json['group_id'],
      userName: json['user_name'],
      profileImage: json['profile_image'],
      type: type,
    );
  }
}
