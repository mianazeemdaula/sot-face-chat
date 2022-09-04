import 'package:meta/meta.dart';
import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  Message({
    required this.sendBy,
    required this.message,
    required this.createdAt,
  });

  final String sendBy;
  final String message;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        sendBy: json["send_by"],
        message: json["message"],
        createdAt: json["created_at"] == null
            ? DateTime.now()
            : json['created_at'].toDate(),
      );

  Map<String, dynamic> toJson() => {
        "send_by": sendBy,
        "message": message,
        "created_at": createdAt,
      };
}
