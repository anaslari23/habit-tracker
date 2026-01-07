import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import 'habit_log_model.dart';
import 'habit_log_repository.dart';

final habitLogRepositoryProvider = Provider((ref) => HabitLogRepository());

final dailyLogsProvider = StreamProvider.family<List<HabitLogModel>, DateTime>((ref, date) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(habitLogRepositoryProvider).streamLogs(userId, date);
});

final allLogsProvider = StreamProvider<List<HabitLogModel>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(habitLogRepositoryProvider).streamAllLogs(userId);
});

final trackingControllerProvider = StateNotifierProvider<TrackingController, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitLogRepositoryProvider);
  final userId = ref.watch(authStateProvider).value?.uid;
  return TrackingController(repository, userId);
});

class TrackingController extends StateNotifier<AsyncValue<void>> {
  final HabitLogRepository _repository;
  final String? _userId;

  TrackingController(this._repository, this._userId) : super(const AsyncValue.data(null));

  Future<void> toggleHabitStatus(String habitId, DateTime date, HabitStatus status) async {
    if (_userId == null) return;

    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final logId = "${habitId}_$dateStr";

    state = const AsyncValue.loading();
    final log = HabitLogModel(
      id: logId,
      habitId: habitId,
      userId: _userId!,
      date: date,
      status: status,
    );
    state = await AsyncValue.guard(() => _repository.updateLog(log));
  }
}
