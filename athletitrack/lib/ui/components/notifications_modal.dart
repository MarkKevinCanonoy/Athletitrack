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
                      final type = req['type'] ?? 'unknown';
                      final isJoin = type == 'join_request';
                      final isApproval = type == 'approval';
                      final isRejection = type == 'rejection';
                      
                      Color iconColor = Colors.orange;
                      IconData iconData = Icons.campaign;
                      
                      if (isJoin) {
                        iconColor = AppColors.primary;
                        iconData = Icons.person_add;
                      } else if (isApproval) {
                        iconColor = AppColors.success;
                        iconData = Icons.check_circle;
                      } else if (isRejection) {
                        iconColor = AppColors.danger;
                        iconData = Icons.cancel;
                      }

                      String timestampText = '';
                      if (req['timestamp'] != null) {
                        try {
                          final dt = DateTime.parse(req['timestamp']).toLocal();
                          timestampText = '${dt.month}/${dt.day}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        } catch (_) {}
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: iconColor),
                          ),
                          child: Icon(iconData, color: iconColor),
                        ),
                        title: Text(
                          req['message'] ?? 'Notification',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (timestampText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(timestampText, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                            if (isJoin) ...[
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
                            ]
                          ],
                        ),
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
