import 'package:flutter/material.dart';
import 'create_post_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/posts_provider.dart';
import 'training_card_modal.dart';
import '../utils/modal_utils.dart';

class TeamFeedList extends ConsumerStatefulWidget {
  final bool isCoach;
  final String teamId;

  const TeamFeedList({
    super.key,
    required this.isCoach,
    required this.teamId,
  });

  @override
  ConsumerState<TeamFeedList> createState() => _TeamFeedListState();
}

class _TeamFeedListState extends ConsumerState<TeamFeedList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProvider.notifier).fetchPosts(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final posts = postsState.posts;

    if (postsState.isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }


    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = posts[index];
        final isTraining = post['type'] == 'training';
        final isWeekly = post['is_weekly'] == true || post['is_weekly'] == 'true';
        final String displayDate = isWeekly 
            ? 'Every ${post['days_of_week'] ?? ''}' 
            : (post['session_date'] ?? 'No date');

        return AppCard(
          child: InkWell(
            onTap: isTraining ? () {
              ModalUtils.showCustomModal(
                context: context, 
                builder: (_) => TrainingCardModal(post: post, isCoach: widget.isCoach, teamId: widget.teamId),
              );
            } : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          AppChip(
                            label: isTraining 
                                ? (isWeekly ? 'Weekly Schedule' : 'One-Time Session') 
                                : 'Announcement',
                          ),
                          Text(
                            displayDate,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                          if (!widget.isCoach && isTraining)
                            IconButton(
                              icon: const Icon(Icons.alarm_add, color: AppColors.primary, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('5-minute reminder set!'))
                                );
                              },
                              tooltip: 'Set Reminder',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                    if (widget.isCoach) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            ModalUtils.showCustomModal(
                              context: context, 
                              builder: (_) => CreatePostModal(teamId: widget.teamId, existingPost: post),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Post'),
                                content: const Text('Are you sure you want to delete this post?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true), 
                                    child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                                  ),
                                ],
                              )
                            );
                            if (confirm == true) {
                              ref.read(postsProvider.notifier).deletePost(widget.teamId, post['id'].toString());
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                          post['title'] ?? '',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                if (post['content'] != null)
                  Text(
                    post['content'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (isTraining && post['session_time'] != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        post['session_time'],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
