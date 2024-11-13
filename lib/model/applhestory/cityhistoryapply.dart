class TodayVoterResponse {
  final List<TodayVoter> todayVoter;

  TodayVoterResponse({required this.todayVoter});

  factory TodayVoterResponse.fromJson(Map<String, dynamic> json) {
    return TodayVoterResponse(
      todayVoter: (json['today_voter'] as List)
          .map((i) => TodayVoter.fromJson(i))
          .toList(),
    );
  }
}

class TodayVoter {
  final int voterId;
  final List<Detail> details;

  TodayVoter({required this.voterId, required this.details});

  factory TodayVoter.fromJson(Map<String, dynamic> json) {
    return TodayVoter(
      voterId: json['voter_id'],
      details: (json['details'] as List).map((i) => Detail.fromJson(i)).toList(),
    );
  }
}

class Detail {
  final String date;
  final String time;
  final int electionId;
  final String type;
  final int totalVotesWinning;
  final String? winnerWithImage;
  final int creditPoint;
  final String? winnerName;

  final String? byVoteName;

  Detail({
    required this.date,
    required this.time,
    required this.electionId,
    required this.type,
    required this.totalVotesWinning,
    this.winnerWithImage,
    required this.creditPoint,
    required this.winnerName,
    required this.byVoteName
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      date: json['date'],
      time: json['time'],
      electionId: json['election_id'],
      type: json['type'],
      totalVotesWinning: json['total_votes_winning'],
      winnerWithImage: json['winner_with_image'],
      creditPoint: json['credit_point'],
      winnerName: json['winner_name'],
      byVoteName: json['ByVoteName'],
    );
  }
}
