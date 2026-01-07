import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderDateTime;
  final bool isPinned;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.reminderDateTime,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reminderDateTime': reminderDateTime != null ? Timestamp.fromDate(reminderDateTime!) : null,
      'isPinned': isPinned,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? (map['createdAt'] as Timestamp).toDate(),
      reminderDateTime: (map['reminderDateTime'] as Timestamp?)?.toDate(),
      isPinned: map['isPinned'] ?? false,
    );
  }

  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? reminderDateTime,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
