import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../data/note_model.dart';
import '../controller/note_controller.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesStreamProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: notesAsync.when(
        data: (notes) {
          final filteredNotes = notes.where((note) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch = note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query);
            return matchesSearch;
          }).toList();

          final pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
          final otherNotes = filteredNotes.where((n) => !n.isPinned).toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                sliver: _buildHeader(context),
              ),
              SliverToBoxAdapter(
                child: _buildWeeklyCalendar(),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: _buildSearchBar(),
              ),
              if (pinnedNotes.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: _buildSectionHeader('PINNED'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: _buildNoteList(pinnedNotes),
                ),
              ],
              if (otherNotes.isNotEmpty) ...[
                if (pinnedNotes.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    sliver: _buildSectionHeader('YOUR NOTES'),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: _buildNoteList(otherNotes),
                ),
              ],
              if (filteredNotes.isEmpty && _searchQuery.isNotEmpty)
                SliverFillRemaining(child: _buildNoResultsState())
              else if (notes.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: 7 - index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isToday ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Journal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Thoughts and reflections',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Search your entries...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w600),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.2), size: 22),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.3),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteList(List<NoteModel> notes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNoteCard(context, ref, note),
          );
        },
        childCount: notes.length,
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, NoteModel note) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          ref.read(noteControllerProvider.notifier).togglePin(note);
          return false;
        }
        return true;
      },
      background: _buildDismissBackground(Icons.push_pin_rounded, AppColors.primary, Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(Icons.delete_outline_rounded, Colors.redAccent, Alignment.centerRight),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          ref.read(noteControllerProvider.notifier).deleteNote(note.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (note.isPinned)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primary),
                        ),
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(note.updatedAt),
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(28)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle),
            child: Icon(Icons.edit_note_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
          ),
          const SizedBox(height: 24),
          const Text('Your journal is empty', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Capture your thoughts and progress.', style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('No matching entries found', style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
