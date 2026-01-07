import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/auth_controller.dart';
import '../../reminders/reminder_repository.dart';
import '../../../core/services/notification_service.dart';
import '../data/note_model.dart';
import '../data/note_firestore.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesStreamProvider = StreamProvider<List<NoteModel>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(noteRepositoryProvider).streamNotes(userId);
});

final noteControllerProvider = StateNotifierProvider<NoteController, AsyncValue<void>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  final userId = ref.watch(authStateProvider).value?.uid;
  return NoteController(repository, userId);
});

class NoteController extends StateNotifier<AsyncValue<void>> {
  final NoteRepository _repository;
  final String? _userId;

  NoteController(this._repository, this._userId) : super(const AsyncValue.data(null));

  Future<void> addNote({
    required String title,
    required String content,
    DateTime? reminderDateTime,
  }) async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    final note = NoteModel(
      id: const Uuid().v4(),
      userId: _userId!,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reminderDateTime: reminderDateTime,
    );

    state = await AsyncValue.guard(() async {
      await _repository.addNote(note);
      if (reminderDateTime != null) {
        await _scheduleReminder(note);
      }
    });
  }

  Future<void> updateNote(NoteModel note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateNote(note.copyWith(updatedAt: DateTime.now()));
      if (note.reminderDateTime != null) {
        await _scheduleReminder(note);
      } else {
        await NotificationService.cancelNotification(note.id.hashCode);
      }
    });
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteNote(noteId);
      await NotificationService.cancelNotification(noteId.hashCode);
    });
  }

  Future<void> togglePin(NoteModel note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateNote(note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      ));
    });
  }

  Future<void> _scheduleReminder(NoteModel note) async {
    if (note.reminderDateTime == null) return;
    
    if (note.reminderDateTime!.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: note.id.hashCode,
        title: 'Note Reminder: ${note.title}',
        body: note.content.length > 50 ? '${note.content.substring(0, 47)}...' : note.content,
        scheduledTime: note.reminderDateTime!,
      );
    }
  }
}
