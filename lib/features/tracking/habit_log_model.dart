import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitStatus { completed, skipped, missed, pending }

class HabitLogModel {
  final String id; // habitId_yyyy-MM-dd
  final String habitId;
  final String userId;
  final DateTime date;
  final HabitStatus status;

  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
    };
  }

  factory HabitLogModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitLogModel(
      id: id,
      habitId: map['habitId'] ?? '',
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: HabitStatus.values.byName(map['status'] ?? 'pending'),
    );
  }
}
