

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../cubits/notes_cubit.dart';
import '../cubits/notes_state.dart';
import '../models/note_model.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';
import 'login_screen.dart';

class NotesListScreen extends StatelessWidget {
  final User user;

  const NotesListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesCubit()..listenToNotes(user.uid),
      child: _NotesListView(user: user),
    );
  }
}

class _NotesListView extends StatelessWidget {
  final User user;
  const _NotesListView({required this.user});

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title:
            const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: Color(0xFFE94560)))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AuthCubit>().signOut();
    }
  }

  Future<void> _handleDeleteNote(
      BuildContext context, NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Delete Note',
            style: TextStyle(color: Colors.white)),
        content: Text('Delete "${note.title}"? This cannot be undone.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Color(0xFFE94560)))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<NotesCubit>().deleteNote(note.id);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to AuthCubit for sign-out navigation
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
        // Listen to NotesCubit for snackbars
        BlocListener<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NotesError) {
              _showSnackBar(context, state.message, isError: true);
            }
            if (state is NotesDeleted) {
              _showSnackBar(context, 'Note deleted.');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16213E),
          elevation: 0,
          title: const Text(
            'My Notes',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                backgroundColor: const Color(0xFFE94560),
                child: user.photoURL == null
                    ? Text(
                        user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              onPressed: () => _handleSignOut(context),
            ),
          ],
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            // Loading
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE94560)),
              );
            }

            // Get notes from whichever state has them
            List<NoteModel> notes = [];
            if (state is NotesLoaded) notes = state.notes;
            if (state is NotesSaving) notes = state.notes;
            if (state is NotesSaved) notes = state.notes;
            if (state is NotesDeleted) notes = state.notes;
            if (state is NotesError) notes = state.notes;

            if (notes.isEmpty) return _buildEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteCard(
                  note: note,
                  formattedDate: _formatDate(note.updatedAt),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<NotesCubit>(),
                        child: NoteDetailScreen(note: note),
                      ),
                    ),
                  ),
                  onDelete: () => _handleDeleteNote(context, note),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<NotesCubit>(),
                child: CreateNoteScreen(userId: user.uid),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFE94560),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Note', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined,
              size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No notes yet',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 20,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Tap the button below to create your first note.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Note Card Widget ──
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.formattedDate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(note.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFE94560), size: 20),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (note.content.isNotEmpty)
                  Text(note.content,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(width: 4),
                    Text(formattedDate,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
