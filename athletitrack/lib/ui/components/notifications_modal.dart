import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/requests_provider.dart';

class NotificationsModal extends ConsumerStatefulWidget {
  const NotificationsModal({super.key});

  @override
  ConsumerState<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends ConsumerState<NotificationsModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(requestsProvider.notifier).fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reqsState = ref.watch(requestsProvider);
    final requests = reqsState.requests;

    return AppCard(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400), margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: reqsState.isLoading && requests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('No new notifications', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: requests.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      final isJoin = req['type'] == 'join_request';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isJoin ? AppColors.primary.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isJoin ? AppColors.primary : Colors.orange,
                            ),
                          ),
                          child: Icon(
                            isJoin ? Icons.person_add : Icons.campaign,
                            color: isJoin ? AppColors.primary : Colors.orange,
                          ),
                        ),
                        title: Text(
                          req['message'] ?? 'Notification',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: isJoin ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: reqsState.isLoading ? null : () => ref.read(requestsProvider.notifier).processRequest(req['id'], 'approve'),
                                  child: const Text('Approve'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: reqsState.isLoading ? null : () => ref.read(requestsProvider.notifier).processRequest(req['id'], 'reject'),
                                  child: const Text('Reject', style: TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          ],
                        ) : null,
                      );
                    },
                  ),
            ),
            const SizedBox(height: 16),
            if (requests.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await ref.read(requestsProvider.notifier).dismissAll();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Dismiss'),
              )
          ],
        ),
      ),
    );
  }
}
