import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final List<int> activeDays; // 1 = Monday, 7 = Sunday
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.activeDays,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'activeDays': activeDays,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      activeDays: List<int>.from(map['activeDays'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  HabitModel copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    List<int>? activeDays,
  }) {
    return HabitModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      activeDays: activeDays ?? this.activeDays,
      createdAt: createdAt,
    );
  }
}
