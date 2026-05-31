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
                  SizedBox(
                    height: 220, // Horizontal scrollable area
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: teams.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return SizedBox(
                          width: 280,
                          child: Hero(
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
