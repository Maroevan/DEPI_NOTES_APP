

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/notes_cubit.dart';
import '../cubits/notes_state.dart';

class CreateNoteScreen extends StatefulWidget {
  final String userId;

  const CreateNoteScreen({super.key, required this.userId});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<NotesCubit>().createNote(
          title: _titleController.text,
          content: _contentController.text,
          userId: widget.userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesCubit, NotesState>(
      listener: (context, state) {
        if (state is NotesSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.of(context).pop();
        }

        if (state is NotesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is NotesSaving;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213E),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('New Note',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            actions: [
              isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFFE94560), strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: () => _handleSave(context),
                      child: const Text('Save',
                          style: TextStyle(
                              color: Color(0xFFE94560),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Title Field ──
                Container(
                  color: const Color(0xFF16213E),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title.';
                      }
                      if (value.trim().length < 2) {
                        return 'Title must be at least 2 characters.';
                      }
                      return null;
                    },
                  ),
                ),
                Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.08),
                    thickness: 1),

                // ── Content Field ──
                Expanded(
                  child: Container(
                    color: const Color(0xFF16213E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: TextFormField(
                      controller: _contentController,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Start typing your note...',
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 16),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please add some content.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                // ── Bottom Save Button ──
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF1A1A2E),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () => _handleSave(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        disabledBackgroundColor:
                            const Color(0xFFE94560).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Save Note',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
