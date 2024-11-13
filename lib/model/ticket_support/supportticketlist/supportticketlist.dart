class SupportTicketList {
  int? id;
  int? userId;
  String? queryType;
  String? querySubject;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;

  SupportTicketList(
      {this.id,
        this.userId,
        this.queryType,
        this.querySubject,
        this.description,
        this.status,
        this.createdAt,
        this.updatedAt});

  SupportTicketList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    queryType = json['query_type'];
    querySubject = json['query_subject'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['query_type'] = this.queryType;
    data['query_subject'] = this.querySubject;
    data['description'] = this.description;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
