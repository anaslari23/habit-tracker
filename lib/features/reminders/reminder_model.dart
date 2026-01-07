import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final String habitId;
  final String userId;
  final TimeOfDay time;
  final List<int> days; // 1 = Monday, 7 = Sunday

  ReminderModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.time,
    required this.days,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'hour': time.hour,
      'minute': time.minute,
      'days': days,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map, String id) {
    return ReminderModel(
      id: id,
      habitId: map['habitId'] ?? '',
      userId: map['userId'] ?? '',
      time: TimeOfDay(hour: map['hour'] ?? 0, minute: map['minute'] ?? 0),
      days: List<int>.from(map['days'] ?? []),
    );
  }
}
