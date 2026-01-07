import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_model.dart';

class HabitFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _habits => _firestore.collection('habits');

  Future<void> createHabit(HabitModel habit) async {
    await _habits.doc(habit.id).set(habit.toMap());
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habits.doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String habitId) async {
    await _habits.doc(habitId).delete();
  }

  Stream<List<HabitModel>> streamHabits(String userId) {
    return _habits
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
