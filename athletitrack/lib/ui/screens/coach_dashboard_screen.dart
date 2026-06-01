import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../components/app_slide_out_menu.dart';
import '../components/common_components.dart';
import '../components/create_team_modal.dart';
import '../components/notifications_modal.dart';
import '../utils/modal_utils.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teams_provider.dart';

class CoachDashboardScreen extends ConsumerStatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  ConsumerState<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends ConsumerState<CoachDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamsProvider.notifier).fetchTeams();
    });
  }

  String _getNextTraining(List<dynamic>? posts) {
    if (posts == null || posts.isEmpty) return 'No scheduled training';
    
    final now = DateTime.now();
    DateTime? nextTraining;
    String? nextTrainingTitle;

    final dayMap = {
      'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7,
      'M': 1, 'T': 2, 'W': 3, 'Th': 4, 'F': 5, 'S': 6, 'Su': 7
    };
    
    DateTime _combineDateAndTime(DateTime baseDate, String? timeString) {
      if (timeString == null || timeString.trim().isEmpty) {
        return DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 59); // Assume end of day if no time
      }
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeString);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int min = int.parse(match.group(2)!);
        // Handle basic 12-hour typing errors if they wrote 1:00 to 5:00 for afternoon
        if (hour >= 1 && hour <= 7 && !timeString.toLowerCase().contains('am')) {
          if (timeString.toLowerCase().contains('pm') || hour < 8) {
            // Very naive heuristic: 1 to 7 is usually PM in sports contexts if AM isn't specified
            // But to be safe, just use the exact parsed time unless PM is explicitly there
            if (timeString.toLowerCase().contains('pm')) hour += 12;
          }
        }
        return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, min);
      }
      return DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 59);
    }

    for (var rawPost in posts) {
      if (rawPost is! Map) continue;
      final post = rawPost;
      
      final isWeekly = post['is_weekly'] == true || post['is_weekly'] == 'true' || post['is_weekly'] == 1 || post['is_weekly'] == '1';
      final title = post['title'] ?? 'Training';
      
      if (!isWeekly && post['session_date'] != null) {
        try {
          final date = DateTime.parse(post['session_date']);
          final exactDateTime = _combineDateAndTime(date, post['session_time']);
          
          if (exactDateTime.isAfter(now)) {
             if (nextTraining == null || exactDateTime.isBefore(nextTraining!)) {
               nextTraining = exactDateTime;
               nextTrainingTitle = title;
             }
          }
        } catch (_) {}
      } else if (isWeekly && post['days_of_week'] != null) {
        final daysOfWeek = (post['days_of_week'] as String).split(',').map((e) => e.trim()).toList();
        final targetDays = daysOfWeek.map((d) => dayMap[d]).where((d) => d != null).cast<int>().toList();
        
        for (int i = 0; i < 8; i++) {
          final checkDate = now.add(Duration(days: i));
          if (targetDays.contains(checkDate.weekday)) {
             final candidate = _combineDateAndTime(checkDate, post['session_time']);
             if (candidate.isAfter(now)) {
               if (nextTraining == null || candidate.isBefore(nextTraining!)) {
                 nextTraining = candidate;
                 nextTrainingTitle = title;
               }
               break;
             }
          }
        }
      }
    }

    if (nextTraining != null) {
      final daysDiff = DateTime(nextTraining!.year, nextTraining!.month, nextTraining!.day)
          .difference(DateTime(now.year, now.month, now.day)).inDays;
      String dayStr = daysDiff == 0 ? 'Today' : (daysDiff == 1 ? 'Tomorrow' : 'In $daysDiff days');
      return '${nextTrainingTitle ?? 'Training'} ($dayStr)';
    }
    
    return 'No upcoming training';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final userName = user?['full_name'] ?? 'Coach';
    
    final teamsState = ref.watch(teamsProvider);
    final teams = teamsState.teams;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'ATHLETITRACK',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 20),
                tooltip: 'Alerts',
                onPressed: () {
                  ModalUtils.showCustomModal(context: context, builder: (_) => const NotificationsModal());
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: AppColors.textPrimary, size: 20),
                tooltip: 'Calendar',
                onPressed: () {
                  context.push('/coach/calendar');
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppSlideOutMenu(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
                if (teamsState.isLoading && teams.isEmpty)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (teams.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'No teams created yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return Hero(
                            tag: 'team-banner-${team['name']}',
                            child: AppCard(
                              onTap: () {
                                context.push('/coach/team/${Uri.encodeComponent(team['name'] ?? 'Team')}', extra: team);
                              },
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -20,
                                    bottom: -20,
                                    child: Icon(
                                      Icons.sports_basketball_outlined,
                                      size: 140,
                                      color: AppColors.textSecondary.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        team['name'] ?? 'Unknown Team',
                                        style: Theme.of(context).textTheme.displaySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${team['athlete_count'] ?? 0} Athletes',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _getNextTraining(team['posts'] as List?),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          if (team['category'] != null) ...[
                                            AppChip(label: team['category']),
                                            const SizedBox(width: 8),
                                          ],
                                          if (team['skill_level'] != null)
                                            AppChip(label: team['skill_level']),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ModalUtils.showCustomModal(
            context: context,
            builder: (context) => const CreateTeamModal(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Team', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
