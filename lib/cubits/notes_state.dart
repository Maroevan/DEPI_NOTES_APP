
import '../models/note_model.dart';

abstract class NotesState {}


class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  NotesLoaded(this.notes);
}

class NotesSaving extends NotesState {
  final List<NoteModel> notes;
  NotesSaving(this.notes);
}

class NotesSaved extends NotesState {
  final List<NoteModel> notes;
  final String message;
  NotesSaved(this.notes, this.message);
}

class NotesDeleted extends NotesState {
  final List<NoteModel> notes;
  NotesSaved get asSaved => NotesSaved(notes, 'Note deleted.');
  NotesDeleted(this.notes);
}

class NotesError extends NotesState {
  final String message;
  final List<NoteModel> notes;
  NotesError(this.message, this.notes);
}
