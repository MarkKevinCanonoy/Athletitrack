import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../components/create_post_modal.dart';
import '../components/attendance_table.dart';
import '../components/team_feed_list.dart';
import '../components/common_components.dart';
import '../components/notifications_modal.dart';
import '../utils/modal_utils.dart';
import '../../core/providers/network_provider.dart';
import '../../core/services/offline_sync_service.dart';
import '../../core/providers/teams_provider.dart';
import 'package:intl/intl.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String teamName;
  final Map<String, dynamic> teamData;
  
  const TeamDetailScreen({super.key, required this.teamName, required this.teamData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkProvider);
    
    String offlineMsg = 'Offline Mode';
    if (!isOnline && teamData['id'] != null) {
      final cached = ref.read(offlineSyncProvider).getCachedTeamFeed(teamData['id']);
      if (cached != null && cached['timestamp'] != null) {
        try {
          final date = DateTime.parse(cached['timestamp']);
          offlineMsg = 'Offline Mode - Data from ${DateFormat('MMM d, h:mm a').format(date)}';
        } catch (_) {}
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(teamName),
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Team'),
                    content: const Text('Are you sure you want to delete this team? Athletes will no longer be able to see it.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true), 
                        child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && teamData['id'] != null) {
                  final success = await ref.read(teamsProvider.notifier).deleteTeam(teamData['id']);
                  if (success && context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Team deleted successfully.')),
                    );
                  } else if (context.mounted) {
                    final errorMsg = ref.read(teamsProvider).error ?? 'Failed to delete team.';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
                    );
                  }
                }
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Feed'),
                      Tab(text: 'Attendance'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isOnline)
                  Container(
                    width: double.infinity,
                    color: AppColors.danger.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, size: 16, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offlineMsg,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Hero(
                    tag: 'team-banner-$teamName',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 140),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
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
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (teamData['logo_url'] != null) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            teamData['logo_url'],
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                      Expanded(
                                        child: Text(
                                          teamName,
                                          style: Theme.of(context).textTheme.displayMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      if (teamData['category'] != null)
                                        AppChip(label: teamData['category']),
                                      if (teamData['skill_level'] != null)
                                        AppChip(label: teamData['skill_level']),
                                      if (teamData['code'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                          ),
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              const Icon(Icons.vpn_key, color: AppColors.primary, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Team Code: ${teamData['code']}',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(text: teamData['code']));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Team code copied to clipboard')),
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(4),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(2.0),
                                                  child: Icon(Icons.copy, size: 16, color: AppColors.primary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      InkWell(
                                        onTap: () {
                                          ModalUtils.showCustomModal(context: context, builder: (_) => const NotificationsModal());
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.person_add_alt_1_outlined, size: 14, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Pending Requests',
                                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                Expanded(
                  child: TabBarView(
                    children: [
                      teamData['id'] != null 
                          ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: TeamFeedList(isCoach: true, teamId: teamData['id'])))
                          : const Center(child: Text('Invalid Team')),
                      teamData['id'] != null 
                          ? Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: AttendanceTable(teamId: teamData['id'], teamName: teamName))
                          : const Center(child: Text('Invalid Team')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (teamData['id'] == null) return;
            ModalUtils.showCustomModal(
              context: context,
              builder: (context) => CreatePostModal(teamId: teamData['id']),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Create Post', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
