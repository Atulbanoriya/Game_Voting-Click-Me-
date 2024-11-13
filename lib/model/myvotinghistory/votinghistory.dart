class MyVotingHistory {
  List<TodayVoter>? todayVoter;

  MyVotingHistory({this.todayVoter});

  MyVotingHistory.fromJson(Map<String, dynamic> json) {
    if (json['today_voter'] != null) {
      todayVoter = <TodayVoter>[];
      json['today_voter'].forEach((v) {
        todayVoter!.add(new TodayVoter.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.todayVoter != null) {
      data['today_voter'] = this.todayVoter!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TodayVoter {
  int? voterId;
  List<Details>? details;

  TodayVoter({this.voterId, this.details});

  TodayVoter.fromJson(Map<String, dynamic> json) {
    voterId = json['voter_id'];
    if (json['details'] != null) {
      details = <Details>[];
      json['details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voter_id'] = this.voterId;
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Details {
  String? date;
  String? time;
  int? electionId;
  String? type;
  int? totalVotesWinning;
  Null? winnerWithImage;
  int? creditPoint;

  Details(
      {this.date,
        this.time,
        this.electionId,
        this.type,
        this.totalVotesWinning,
        this.winnerWithImage,
        this.creditPoint});

  Details.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
    electionId = json['election_id'];
    type = json['type'];
    totalVotesWinning = json['total_votes_winning'];
    winnerWithImage = json['winner_with_image'];
    creditPoint = json['credit_point'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['time'] = this.time;
    data['election_id'] = this.electionId;
    data['type'] = this.type;
    data['total_votes_winning'] = this.totalVotesWinning;
    data['winner_with_image'] = this.winnerWithImage;
    data['credit_point'] = this.creditPoint;
    return data;
  }
}
