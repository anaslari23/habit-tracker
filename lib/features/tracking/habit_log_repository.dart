import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_log_model.dart';

class HabitLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _logs => _firestore.collection('habit_logs');

  Future<void> updateLog(HabitLogModel log) async {
    await _logs.doc(log.id).set(log.toMap());
  }

  Stream<List<HabitLogModel>> streamLogs(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _logs
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<HabitLogModel>> streamAllLogs(String userId) {
    return _logs
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
