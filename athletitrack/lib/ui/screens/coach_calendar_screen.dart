import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../components/common_components.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_client.dart';

class CoachCalendarScreen extends ConsumerStatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  ConsumerState<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends ConsumerState<CoachCalendarScreen> {
  Map<int, List<Map<String, dynamic>>> _scheduledDays = {};
  List<Map<String, dynamic>> _todaySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    try {
      final response = await ApiClient().dio.post('/get_calendar_posts.php', data: {
        'user_id': user['id'],
      });

      if (response.data['status'] == 'success') {
        final List<dynamic> rawPosts = response.data['posts'] ?? [];
        final List<Map<String, dynamic>> posts = rawPosts.cast<Map<String, dynamic>>();

        final Map<int, List<Map<String, dynamic>>> scheduled = {};
        
        final today = DateTime.now();
        final currentMonth = today.month;
        final currentYear = today.year;

        final dayMap = {
          'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7,
          'M': 1, 'T': 2, 'W': 3, 'Th': 4, 'F': 5, 'S': 6, 'Su': 7
        };

        for (var post in posts) {
          final isWeekly = post['is_weekly'] == true || post['is_weekly'] == 'true' || post['is_weekly'] == 1 || post['is_weekly'] == '1';
          final title = post['title'] ?? 'Training';

          void addPostToDay(int day) {
            if (scheduled[day] == null) {
              scheduled[day] = [];
            }
            scheduled[day]!.add(post);
          }

          if (!isWeekly && post['session_date'] != null) {
            try {
              final d = DateTime.parse(post['session_date']);
              if (d.month == currentMonth && d.year == currentYear) {
                addPostToDay(d.day);
              }
            } catch (_) {}
          } else if (isWeekly && post['days_of_week'] != null) {
            final daysOfWeek = (post['days_of_week'] as String).split(',').map((e) => e.trim()).toList();
            final targetDays = daysOfWeek.map((d) => dayMap[d]).where((d) => d != null).cast<int>().toList();
            
            // Go through all days of the current month
            final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
            for (int i = 1; i <= daysInMonth; i++) {
              final currentDay = DateTime(currentYear, currentMonth, i);
              if (targetDays.contains(currentDay.weekday)) {
                addPostToDay(i);
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _scheduledDays = scheduled;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Calendar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 24),
                        // Days of week header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                              .map((day) => Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Calendar Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          // Calendar logic
                          itemCount: 42, // fixed 6 weeks grid
                          itemBuilder: (context, index) {
                            final now = DateTime.now();
                            final firstDayOfMonth = DateTime(now.year, now.month, 1);
                            final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
                            
                            // 1 (Monday) to 7 (Sunday)
                            // We want Sunday to be first (index 0 in our row), so:
                            int startingOffset = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
                            
                            if (index < startingOffset || index >= startingOffset + daysInMonth) {
                              return const SizedBox.shrink();
                            }
                            
                            final day = index - startingOffset + 1;
                            final dayPosts = _scheduledDays[day] ?? [];
                            final isScheduled = dayPosts.isNotEmpty;

                            return InkWell(
                              onTap: isScheduled ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: AppColors.surface,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 400),
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Sessions on ${_getMonthName(now.month)} $day',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () => Navigator.pop(context),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Flexible(
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              itemCount: dayPosts.length,
                                              separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                                              itemBuilder: (context, idx) {
                                                final p = dayPosts[idx];
                                                final teamName = p['teams'] != null ? p['teams']['name'] : 'Unknown Team';
                                                final time = p['session_time'] ?? 'No time set';
                                                final title = p['title'] ?? 'Training';
                                                final isWeekly = p['is_weekly'] == true || p['is_weekly'] == 'true' || p['is_weekly'] == 1 || p['is_weekly'] == '1';
                                                final typeStr = isWeekly ? 'Weekly Recurring' : 'One-Time';
                                                
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.group, size: 14, color: AppColors.textSecondary),
                                                          const SizedBox(width: 4),
                                                          Text(teamName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                                                          const SizedBox(width: 4),
                                                          Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                                                          const SizedBox(width: 4),
                                                          Text(typeStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isScheduled ? AppColors.primary : AppColors.border,
                                    width: isScheduled ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                        color: isScheduled ? AppColors.textPrimary : AppColors.textSecondary,
                                        fontWeight: isScheduled ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (isScheduled)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                          child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: dayPosts.length,
                                            itemBuilder: (context, idx) {
                                              final title = dayPosts[idx]['title'] ?? 'Training';
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 2.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 10, height: 1.1)),
                                                    Expanded(
                                                      child: Text(
                                                        title,
                                                        style: const TextStyle(
                                                          fontSize: 9,
                                                          color: AppColors.primary,
                                                          height: 1.1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
