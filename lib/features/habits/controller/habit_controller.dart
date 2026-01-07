import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/auth_controller.dart';
import '../data/habit_firestore.dart';
import '../data/habit_model.dart';
import '../data/habit_repository.dart';

final habitFirestoreProvider = Provider((ref) => HabitFirestore());

final habitRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(habitFirestoreProvider);
  return HabitRepository(firestore);
});

final habitsStreamProvider = StreamProvider<List<HabitModel>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(habitRepositoryProvider).watchHabits(userId);
});

final habitControllerProvider = StateNotifierProvider<HabitController, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final userId = ref.watch(authStateProvider).value?.uid;
  return HabitController(repository, userId);
});

class HabitController extends StateNotifier<AsyncValue<void>> {
  final HabitRepository _repository;
  final String? _userId;

  HabitController(this._repository, this._userId) : super(const AsyncValue.data(null));

  Future<String?> addHabit({
    required String title,
    String? description,
    required DateTime startDate,
    required List<int> activeDays,
  }) async {
    if (_userId == null) return null;

    state = const AsyncValue.loading();
    final habitId = const Uuid().v4();
    final habit = HabitModel(
      id: habitId,
      userId: _userId!,
      title: title,
      description: description,
      startDate: startDate,
      activeDays: activeDays,
      createdAt: DateTime.now(),
    );
    state = await AsyncValue.guard(() => _repository.addHabit(habit));
    return habitId;
  }

  Future<void> updateHabit(HabitModel habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateHabit(habit));
  }

  Future<void> deleteHabit(String habitId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteHabit(habitId));
  }
}
