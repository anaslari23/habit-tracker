import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/note_controller.dart';
import '../data/note_model.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  DateTime? _reminderDateTime;
  bool _isPinned = false;
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _reminderDateTime = widget.note?.reminderDateTime;
    _isPinned = widget.note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now().add(const Duration(minutes: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? DateTime.now().add(const Duration(minutes: 5))),
      );

      if (time != null) {
        setState(() {
          _reminderDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final title = _titleController.text.isEmpty ? 'Untitled Note' : _titleController.text.trim();

    if (widget.note == null) {
      await ref.read(noteControllerProvider.notifier).addNote(
            title: title,
            content: _contentController.text.trim(),
            reminderDateTime: _reminderDateTime,
          );
    } else {
      await ref.read(noteControllerProvider.notifier).updateNote(
            widget.note!.copyWith(
              title: title,
              content: _contentController.text.trim(),
              reminderDateTime: _reminderDateTime,
              isPinned: _isPinned,
            ),
          );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _saveNote,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isPinned = !_isPinned),
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.primary : Colors.white.withOpacity(0.3),
              size: 22,
            ),
          ),
          IconButton(
            onPressed: _pickReminder,
            icon: Icon(
              _reminderDateTime == null ? Icons.add_alarm_rounded : Icons.alarm_on_rounded,
              color: _reminderDateTime == null ? Colors.white.withOpacity(0.3) : AppColors.primary,
              size: 22,
            ),
          ),
          TextButton(
            onPressed: _saveNote,
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              children: [
                if (widget.note != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      DateFormat('MMMM d, y • HH:mm').format(widget.note!.updatedAt),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                  decoration: InputDecoration(
                    hintText: 'Entry Title',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                  ),
                  onSubmitted: (_) => _contentFocusNode.requestFocus(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18, height: 1.6, fontWeight: FontWeight.w500),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ],
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? 8 : MediaQuery.of(context).padding.bottom + 12,
        top: 12,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildToolbarAction(Icons.checklist_rounded, () {}),
              const SizedBox(width: 16),
              _buildToolbarAction(Icons.camera_alt_rounded, () {}),
              const SizedBox(width: 16),
              _buildToolbarAction(Icons.draw_rounded, () {}),
            ],
          ),
          _buildToolbarAction(Icons.format_size_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildToolbarAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: Colors.white.withOpacity(0.4), size: 22),
    );
  }
}
