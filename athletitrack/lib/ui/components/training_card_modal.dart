import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'upload_proof_modal.dart';
import '../utils/modal_utils.dart';
import 'post_submissions_list.dart';

class TrainingCardModal extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isCoach;
  final String teamId;

  const TrainingCardModal({
    super.key, 
    required this.post, 
    required this.isCoach,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekly = post['is_weekly'] == true || post['is_weekly'] == 'true';
    final String sessionTime = post['session_time'] ?? 'No Time Set';
    final List<String> days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
    final dayMap = {'Mon': 'M', 'Tue': 'T', 'Wed': 'W', 'Thu': 'Th', 'Fri': 'F', 'Sat': 'S', 'Sun': 'Su'};
    
    // Parse scheduled days if weekly
    List<String> scheduledDays = [];
    if (isWeekly && post['days_of_week'] != null) {
      final parts = (post['days_of_week'] as String).split(',').map((e) => e.trim()).toList();
      for (var p in parts) {
        if (dayMap.containsKey(p)) {
          scheduledDays.add(dayMap[p]!);
        } else {
          scheduledDays.add(p);
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with subtle gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.1), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      isWeekly ? 'Weekly Routine' : 'One-Time Session',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        sessionTime,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      if (isWeekly) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: days.map((day) {
                            final isScheduled = scheduledDays.contains(day);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isScheduled ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isScheduled ? AppColors.primary : AppColors.border,
                                  width: 1.5,
                                ),
                                boxShadow: isScheduled ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ] : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isScheduled ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isScheduled ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ] else if (post['session_date'] != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                post['session_date'],
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      
                      if (post['title'] != null) ...[
                        Text(
                          post['title'],
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (post['content'] != null)
                        Text(
                          post['content'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                      const SizedBox(height: 40),
                      
                      if (isCoach) ...[
                        const Divider(),
                        PostSubmissionsList(teamId: teamId, postId: post['id'].toString()),
                      ],
                      
                      if (!isCoach) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ModalUtils.showCustomModal(
                                    context: context, 
                                    builder: (context) => UploadProofModal(isExcuse: false, post: post, teamId: teamId)
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.cloud_upload_rounded),
                                label: const Text('Upload Proof', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ModalUtils.showCustomModal(
                                    context: context, 
                                    builder: (context) => UploadProofModal(isExcuse: true, post: post, teamId: teamId)
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.border, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.edit_note_rounded),
                                label: const Text('Submit Excuse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
