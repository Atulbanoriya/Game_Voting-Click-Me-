import 'dart:convert';

SlotBook slotBookFromJson(String str) => SlotBook.fromJson(json.decode(str));

String slotBookToJson(SlotBook data) => json.encode(data.toJson());

class SlotBook {
  List<Slot> slots;

  SlotBook({
    required this.slots,
  });

  factory SlotBook.fromJson(Map<String, dynamic> json) => SlotBook(
    slots: List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
  };
}

class Slot {
  int id;
  String name;
  String type;
  DateTime appStartTime;
  DateTime appEndTime;
  DateTime electStartTime;
  DateTime electEndTime;
  DateTime createdAt;
  DateTime updatedAt;

  Slot({
    required this.id,
    required this.name,
    required this.type,
    required this.appStartTime,
    required this.appEndTime,
    required this.electStartTime,
    required this.electEndTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json["id"],
    name: json["name"],
    type: json["type"],
    appStartTime: DateTime.parse(json["app_start_time"]),
    appEndTime: DateTime.parse(json["app_end_time"]),
    electStartTime: DateTime.parse(json["elect_start_time"]),
    electEndTime: DateTime.parse(json["elect_end_time"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "app_start_time": appStartTime.toIso8601String(),
    "app_end_time": appEndTime.toIso8601String(),
    "elect_start_time": electStartTime.toIso8601String(),
    "elect_end_time": electEndTime.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
