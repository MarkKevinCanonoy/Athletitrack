import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../components/team_feed_list.dart';
import '../../core/providers/network_provider.dart';
import '../../core/services/offline_sync_service.dart';
import 'package:intl/intl.dart';

class AthleteTeamFeedScreen extends ConsumerWidget {
  final String teamName;
  final Map<String, dynamic> teamData;

  const AthleteTeamFeedScreen({super.key, required this.teamName, required this.teamData});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                        height: 140,
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
                                  Text(
                                    teamName,
                                    style: Theme.of(context).textTheme.displayMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Athlete Feed',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
                  child: TeamFeedList(
                    isCoach: false,
                    teamId: teamData['id'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
