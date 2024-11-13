class SupportHsitory {
  String? queryType;
  String? querySubject;
  String? description;
  int? userId;
  String? updatedAt;
  String? createdAt;
  int? id;

  SupportHsitory(
      {this.queryType,
        this.querySubject,
        this.description,
        this.userId,
        this.updatedAt,
        this.createdAt,
        this.id});

  SupportHsitory.fromJson(Map<String, dynamic> json) {
    queryType = json['query_type'];
    querySubject = json['query_subject'];
    description = json['description'];
    userId = json['user_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['query_type'] = this.queryType;
    data['query_subject'] = this.querySubject;
    data['description'] = this.description;
    data['user_id'] = this.userId;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
