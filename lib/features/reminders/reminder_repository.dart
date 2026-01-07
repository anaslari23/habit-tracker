import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder_model.dart';

class ReminderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _reminders => _firestore.collection('reminders');

  Future<void> addReminder(ReminderModel reminder) async {
    await _reminders.doc(reminder.id).set(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _reminders.doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String reminderId) async {
    await _reminders.doc(reminderId).delete();
  }

  Stream<List<ReminderModel>> streamReminders(String userId) {
    return _reminders
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReminderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
