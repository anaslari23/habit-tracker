import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_model.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NoteModel>> streamNotes(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('isPinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addNote(NoteModel note) async {
    await _firestore.collection('notes').doc(note.id).set(note.toMap());
  }

  Future<void> updateNote(NoteModel note) async {
    await _firestore.collection('notes').doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
