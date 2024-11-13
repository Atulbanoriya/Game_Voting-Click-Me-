class totalCountVotes {
  int? voteTotal;
  int? countTotalVote;
  int? countPendingVote;

  totalCountVotes({this.voteTotal, this.countTotalVote, this.countPendingVote});

  totalCountVotes.fromJson(Map<String, dynamic> json) {
    voteTotal = json['voteTotal'];
    countTotalVote = json['countTotalVote'];
    countPendingVote = json['countPendingVote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voteTotal'] = this.voteTotal;
    data['countTotalVote'] = this.countTotalVote;
    data['countPendingVote'] = this.countPendingVote;
    return data;
  }
}