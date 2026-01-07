import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../../reminders/reminder_controller.dart';
import '../controller/habit_controller.dart';
import '../data/habit_model.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final HabitModel? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  final List<int> _activeDays = [1, 2, 3, 4, 5, 6, 7];
  bool _setReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _descriptionController.text = widget.habit!.description ?? '';
      _startDate = widget.habit!.startDate;
      _activeDays.clear();
      _activeDays.addAll(widget.habit!.activeDays);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_activeDays.contains(day)) {
        if (_activeDays.length > 1) {
          _activeDays.remove(day);
        }
      } else {
        _activeDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: AppColors.premiumBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.habit == null ? 'Create Habit' : 'Edit Habit',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Title & Aim'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g. Morning Workout',
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Description (Optional)',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Start Date'),
            const SizedBox(height: 12),
            _buildDatePicker(context),
            const SizedBox(height: 32),
            _buildSectionTitle('Repeat on days'),
            const SizedBox(height: 16),
            _buildDaySelector(days),
            const SizedBox(height: 32),
            _buildReminderSection(context),
            const SizedBox(height: 60),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.3),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (selectedDate != null) setState(() => _startDate = selectedDate);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM d, y').format(_startDate),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(List<String> days) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isSelected = _activeDays.contains(day);
        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFF1C1F26),
              shape: BoxShape.circle,
              boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
            ),
            child: Text(
              days[index].substring(0, 1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Daily Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            subtitle: Text('Get notified to log your habit', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
            value: _setReminder,
            onChanged: (v) => setState(() => _setReminder = v),
            activeColor: AppColors.primary,
          ),
          if (_setReminder) ...[
            const Divider(color: Colors.white10, height: 1),
            ListTile(
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _reminderTime);
                if (time != null) setState(() => _reminderTime = time);
              },
              title: const Text('Reminder Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              trailing: Text(_reminderTime.format(context), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                if (widget.habit == null) {
                  final habitId = await ref.read(habitControllerProvider.notifier).addHabit(
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        startDate: _startDate,
                        activeDays: _activeDays,
                      );
                  if (habitId != null && _setReminder) {
                    await ref.read(reminderControllerProvider.notifier).addReminder(
                          habitId: habitId,
                          habitTitle: _titleController.text.trim(),
                          time: _reminderTime,
                          days: _activeDays,
                        );
                  }
                } else {
                  await ref.read(habitControllerProvider.notifier).updateHabit(
                        widget.habit!.copyWith(
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          startDate: _startDate,
                          activeDays: _activeDays,
                        ),
                      );
                  if (_setReminder) {
                    await ref.read(reminderControllerProvider.notifier).addReminder(
                          habitId: widget.habit!.id,
                          habitTitle: _titleController.text.trim(),
                          time: _reminderTime,
                          days: _activeDays,
                        );
                  }
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(
              widget.habit == null ? 'CREATE HABIT' : 'SAVE CHANGES',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ),
        if (widget.habit != null) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(habitControllerProvider.notifier).deleteHabit(widget.habit!.id);
              Navigator.pop(context);
            },
            child: const Text('Delete Habit', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ),
        ],
      ],
    );
  }
}

