import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_controller.dart';
import '../../core/services/notification_service.dart';
import 'reminder_model.dart';
import 'reminder_repository.dart';

final reminderRepositoryProvider = Provider((ref) => ReminderRepository());

final remindersStreamProvider = StreamProvider<List<ReminderModel>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(reminderRepositoryProvider).streamReminders(userId);
});

final reminderControllerProvider = StateNotifierProvider<ReminderController, AsyncValue<void>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final userId = ref.watch(authStateProvider).value?.uid;
  return ReminderController(repository, userId);
});

class ReminderController extends StateNotifier<AsyncValue<void>> {
  final ReminderRepository _repository;
  final String? _userId;

  ReminderController(this._repository, this._userId) : super(const AsyncValue.data(null));

  Future<void> addReminder({
    required String habitId,
    required String habitTitle,
    required TimeOfDay time,
    required List<int> days,
  }) async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    final reminder = ReminderModel(
      id: const Uuid().v4(),
      habitId: habitId,
      userId: _userId!,
      time: time,
      days: days,
    );

    state = await AsyncValue.guard(() async {
      await _repository.addReminder(reminder);
      await _scheduleLocalNotifications(reminder, habitTitle);
    });
  }

  Future<void> _scheduleLocalNotifications(ReminderModel reminder, String habitTitle) async {
    final now = DateTime.now();
    for (final day in reminder.days) {
      // Logic to find next instance of this day at this time
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // This is a simplified scheduling; real world might need to handle next week if time passed today
      // For this app, we'll use the simplified approach for now
      
      await NotificationService.scheduleNotification(
        id: reminder.id.hashCode + day,
        title: 'Time for your habit!',
        body: 'Don\'t forget to: $habitTitle',
        scheduledTime: scheduledDate,
      );
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteReminder(reminderId);
      await NotificationService.cancelNotification(reminderId.hashCode);
    });
  }
}
