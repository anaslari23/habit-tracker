import 'habit_firestore.dart';
import 'habit_model.dart';

class HabitRepository {
  final HabitFirestore _firestore;

  HabitRepository(this._firestore);

  Future<void> addHabit(HabitModel habit) => _firestore.createHabit(habit);
  Future<void> updateHabit(HabitModel habit) => _firestore.updateHabit(habit);
  Future<void> deleteHabit(String habitId) => _firestore.deleteHabit(habitId);
  Stream<List<HabitModel>> watchHabits(String userId) => _firestore.streamHabits(userId);
}
