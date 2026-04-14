
import '../models/note_model.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

// Notes loaded successfully
class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  NotesLoaded(this.notes);
}

// Saving (create or update) in progress
class NotesSaving extends NotesState {
  final List<NoteModel> notes; // keep existing list visible while saving
  NotesSaving(this.notes);
}

// A note was saved (created or updated) successfully
class NotesSaved extends NotesState {
  final List<NoteModel> notes;
  final String message;
  NotesSaved(this.notes, this.message);
}

// A note was deleted successfully
class NotesDeleted extends NotesState {
  final List<NoteModel> notes;
  NotesSaved get asSaved => NotesSaved(notes, 'Note deleted.');
  NotesDeleted(this.notes);
}

// Error state
class NotesError extends NotesState {
  final String message;
  final List<NoteModel> notes; // keep existing list visible on error
  NotesError(this.message, this.notes);
}
