import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/posts_provider.dart';

class CreatePostModal extends ConsumerStatefulWidget {
  final String teamId;
  final Map<String, dynamic>? existingPost;

  const CreatePostModal({super.key, required this.teamId, this.existingPost});

  @override
  ConsumerState<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends ConsumerState<CreatePostModal> {
  String postType = 'Announcement';
  String targetSkillLevel = 'All';
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _daysController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      final p = widget.existingPost!;
      _titleController.text = p['title'] ?? '';
      _contentController.text = p['content'] ?? '';
      targetSkillLevel = p['target_skill_level'] ?? 'All';
      final isWeekly = p['is_weekly'] == true || p['is_weekly'] == 'true';
      if (p['type'] == 'training') {
        postType = isWeekly ? 'Weekly Schedule' : 'One-Time Training';
        if (isWeekly) {
          _daysController.text = p['days_of_week'] ?? '';
          if (p['session_time'] != null) {
            final parts = p['session_time'].split('-');
            if (parts.length >= 2) {
              _startTimeController.text = parts[0].trim();
              _endTimeController.text = parts[1].trim();
            } else {
              _startTimeController.text = p['session_time'];
            }
          }
        } else {
          _dateController.text = p['session_date'] ?? '';
          if (p['session_time'] != null) {
            final parts = p['session_time'].split('-');
            if (parts.length >= 2) {
              _startTimeController.text = parts[0].trim();
              _endTimeController.text = parts[1].trim();
            } else {
              _startTimeController.text = p['session_time'];
            }
          }
        }
      } else {
        postType = 'Announcement';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _daysController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_titleController.text.trim().isEmpty) return;

    String type = 'announcement';
    if (postType == 'One-Time Training') type = 'training';
    if (postType == 'Weekly Schedule') type = 'training';

    final sessionTimeValue = '${_startTimeController.text.trim()}' + 
        (_endTimeController.text.trim().isNotEmpty ? ' - ${_endTimeController.text.trim()}' : '');

    bool success = false;
    if (widget.existingPost != null) {
      success = await ref.read(postsProvider.notifier).editPost(
        teamId: widget.teamId,
        postId: widget.existingPost!['id'].toString(),
        type: type,
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
        sessionDate: postType == 'One-Time Training' ? _dateController.text.trim() : null,
        sessionTime: (postType == 'Weekly Schedule' || postType == 'One-Time Training') ? sessionTimeValue : null,
        isWeekly: postType == 'Weekly Schedule',
        daysOfWeek: postType == 'Weekly Schedule' ? _daysController.text.trim() : null,
        targetSkillLevel: targetSkillLevel,
      );
    } else {
      success = await ref.read(postsProvider.notifier).createPost(
        teamId: widget.teamId,
        type: type,
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
        sessionDate: postType == 'One-Time Training' ? _dateController.text.trim() : null,
        sessionTime: (postType == 'Weekly Schedule' || postType == 'One-Time Training') ? sessionTimeValue : null,
        isWeekly: postType == 'Weekly Schedule',
        daysOfWeek: postType == 'Weekly Schedule' ? _daysController.text.trim() : null,
        targetSkillLevel: targetSkillLevel,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    return AppCard(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400), margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existingPost != null ? 'Edit Post' : 'Create Post', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: postType,
              decoration: const InputDecoration(labelText: 'Post Type'),
              items: ['Announcement', 'One-Time Training', 'Weekly Schedule']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: widget.existingPost != null ? null : (val) {
                if (val != null) setState(() => postType = val);
              },
              dropdownColor: AppColors.surface,
            ),
            const SizedBox(height: 16),
            if (postType != 'Announcement') ...[
              DropdownButtonFormField<String>(
                value: targetSkillLevel,
                decoration: const InputDecoration(labelText: 'Target Skill Level'),
                items: ['All', 'Beginner', 'Intermediate', 'Expert']
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => targetSkillLevel = val);
                },
                dropdownColor: AppColors.surface,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Description / Instructions'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (postType == 'One-Time Training') ...[
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', suffixIcon: Icon(Icons.calendar_today, size: 20))
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: _startTimeController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null && context.mounted) {
                        _startTimeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Start Time (HH:MM)', suffixIcon: Icon(Icons.access_time, size: 20))
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(
                    controller: _endTimeController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null && context.mounted) {
                        _endTimeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: const InputDecoration(labelText: 'End Time (Optional)', suffixIcon: Icon(Icons.access_time, size: 20))
                  )),
                ],
              ),
              const SizedBox(height: 16),
            ] else if (postType == 'Weekly Schedule') ...[
              TextField(controller: _daysController, decoration: const InputDecoration(labelText: 'Recurring Days (e.g., M,W,F)')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: _startTimeController, 
                    readOnly: true,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null && context.mounted) {
                        _startTimeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Start Time (HH:MM)', suffixIcon: Icon(Icons.access_time, size: 20))
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(
                    controller: _endTimeController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null && context.mounted) {
                        _endTimeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    }, 
                    decoration: const InputDecoration(labelText: 'End Time (HH:MM)', suffixIcon: Icon(Icons.access_time, size: 20))
                  )),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (postsState.error != null) ...[
              Text(postsState.error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: postsState.isLoading ? null : _submit,
              child: postsState.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.existingPost != null ? 'Save Changes' : 'Publish Post'),
            )
          ],
        ),
      ),
    );
  }
}
