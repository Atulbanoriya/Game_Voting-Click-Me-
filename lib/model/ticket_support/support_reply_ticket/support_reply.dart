class TicketReply {
  final int id;
  final int ticketId;
  final int userId;
  final String message;
  final String type;
  final String createdAt;
  final String updatedAt;

  TicketReply({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id'],
      ticketId: json['ticket_id'],
      userId: json['user_id'],
      message: json['message'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
