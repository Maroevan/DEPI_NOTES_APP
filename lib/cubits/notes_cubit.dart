

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note_model.dart';
import '../services/firebase_service.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  // Keep a local copy of notes for error/saving states
  List<NoteModel> _currentNotes = [];

  NotesCubit() : super(NotesInitial());

  
  // Start listening to Firestore in real-time

  void listenToNotes(String userId) {
    emit(NotesLoading());

    _notesSubscription?.cancel();

    _notesSubscription =
        _firebaseService.getNotesStream(userId).listen((notes) {
      _currentNotes = notes;
      emit(NotesLoaded(notes));
    }, onError: (_) {
      emit(NotesError('Failed to load notes. Please try again.', _currentNotes));
    });
  }

  // Create Note

  Future<void> createNote({
    required String title,
    required String content,
    required String userId,
  }) async {
    emit(NotesSaving(_currentNotes));

    try {
      await _firebaseService.createNote(
        title: title.trim(),
        content: content.trim(),
        userId: userId,
      );
      // Stream will auto-update _currentNotes via listenToNotes
      emit(NotesSaved(_currentNotes, 'Note created successfully!'));
    } catch (_) {
      emit(NotesError('Failed to create note. Please try again.', _currentNotes));
    }
  }

  // Update Note

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    emit(NotesSaving(_currentNotes));

    try {
      await _firebaseService.updateNote(
        noteId: noteId,
        title: title.trim(),
        content: content.trim(),
      );
      emit(NotesSaved(_currentNotes, 'Note updated successfully!'));
    } catch (_) {
      emit(NotesError('Failed to update note. Please try again.', _currentNotes));
    }
  }

  // Delete Note

  Future<void> deleteNote(String noteId) async {
    try {
      await _firebaseService.deleteNote(noteId);
      emit(NotesDeleted(_currentNotes));
    } catch (_) {
      emit(NotesError('Failed to delete note. Please try again.', _currentNotes));
    }
  }

  // Cleanup

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
