
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/notes_cubit.dart';
import '../cubits/notes_state.dart';
import '../models/note_model.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _titleController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final changed = _titleController.text != widget.note.title ||
        _contentController.text != widget.note.content;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleUpdate(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<NotesCubit>().updateNote(
          noteId: widget.note.id,
          title: _titleController.text,
          content: _contentController.text,
        );
  }

  Future<bool> _handleBackPress() async {
    if (_isEditing && _hasChanges) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text('Discard changes?',
              style: TextStyle(color: Colors.white)),
          content: const Text('You have unsaved changes. Discard them?',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep Editing')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard',
                    style: TextStyle(color: Color(0xFFE94560)))),
          ],
        ),
      );
      return discard ?? false;
    }
    return true;
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} · '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: BlocConsumer<NotesCubit, NotesState>(
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
            setState(() {
              _isEditing = false;
              _hasChanges = false;
            });
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
                onPressed: () async {
                  final canPop = await _handleBackPress();
                  if (canPop && mounted) Navigator.of(context).pop();
                },
              ),
              title: Text(
                _isEditing ? 'Edit Note' : 'Note',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
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
                    : _isEditing
                        ? TextButton(
                            onPressed: () => _handleUpdate(context),
                            child: const Text('Save',
                                style: TextStyle(
                                    color: Color(0xFFE94560),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          )
                        : IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white70),
                            onPressed: () =>
                                setState(() => _isEditing = true),
                          ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata
                  Container(
                    color: const Color(0xFF16213E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        Text(
                          'Updated ${_formatFullDate(widget.note.updatedAt)}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.08),
                      thickness: 1),

                  // Title
                  Container(
                    color: const Color(0xFF16213E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: TextFormField(
                      controller: _titleController,
                      enabled: _isEditing,
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
                        enabledBorder: _isEditing
                            ? const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFE94560), width: 1.5))
                            : InputBorder.none,
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFE94560), width: 2)),
                        disabledBorder: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title cannot be empty.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.08),
                      thickness: 1),

                  // Content
                  Expanded(
                    child: Container(
                      color: const Color(0xFF16213E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: TextFormField(
                        controller: _contentController,
                        enabled: _isEditing,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 16,
                            height: 1.6),
                        decoration: InputDecoration(
                          hintText: 'Content...',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 16),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Content cannot be empty.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  // Bottom Update Button
                  if (_isEditing)
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFF1A1A2E),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              isSaving ? null : () => _handleUpdate(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            disabledBackgroundColor:
                                const Color(0xFFE94560).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('Update Note',
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
      ),
    );
  }
}
