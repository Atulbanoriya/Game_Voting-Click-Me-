class usertotalrecord {
  int? totalUser;
  int? totalElection;
  int? totalTodayElection;
  String? userName;
  String? userWalletAmount;
  int? totalVoter;
  int? todayVoter;

  usertotalrecord(
      {this.totalUser,
        this.totalElection,
        this.totalTodayElection,
        this.userName,
        this.userWalletAmount,
        this.totalVoter,
        this.todayVoter});

  usertotalrecord.fromJson(Map<String, dynamic> json) {
    totalUser = json['total_user'];
    totalElection = json['total_election'];
    totalTodayElection = json['total_today_election'];
    userName = json['user_name'];
    userWalletAmount = json['user_wallet_amount'];
    totalVoter = json['total_voter'];
    todayVoter = json['today_voter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_user'] = this.totalUser;
    data['total_election'] = this.totalElection;
    data['total_today_election'] = this.totalTodayElection;
    data['user_name'] = this.userName;
    data['user_wallet_amount'] = this.userWalletAmount;
    data['total_voter'] = this.totalVoter;
    data['today_voter'] = this.todayVoter;
    return data;
  }
}
