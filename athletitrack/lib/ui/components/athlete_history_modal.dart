import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';

class AthleteHistoryModal extends StatelessWidget {
  final Map<String, dynamic> row;

  const AthleteHistoryModal({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> attendance = row['attendance'];

    int completed = 0;
    int missed = 0;
    int pending = 0;

    for (var session in attendance) {
      if (session['status'] == 'approved') {
        completed++;
      } else if (session['status'] == 'rejected' ||
          session['status'] == 'missing') {
        missed++;
      } else if (session['status'] == 'pending') {
        pending++;
      }
    }

    int total = completed + missed + pending;
    double complianceRate = total > 0 ? (completed / total) * 100 : 0;

    return AppCard(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${row['name']}\'s History',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stat cards in styled containers
              Row(
                children: [
                  _buildStatCard('Completed', completed, AppColors.success),
                  const SizedBox(width: 8),
                  _buildStatCard('Missed', missed, AppColors.danger),
                  const SizedBox(width: 8),
                  _buildStatCard('Pending', pending, Colors.orange),
                ],
              ),
              const SizedBox(height: 20),

              // Compliance rate label
              Text(
                'Compliance Rate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Compliance percentage
              Text(
                '${complianceRate.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _complianceColor(complianceRate),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Visual compliance progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _complianceColor(complianceRate),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Session breakdown header
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              Text(
                'Session Breakdown',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),

              // Per-session list
              if (attendance.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No sessions recorded yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...attendance.map<Widget>((session) {
                  return _buildSessionTile(context, session);
                }),

              const SizedBox(height: 16),

              // Close button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled stat card that flexes evenly within its parent Row.
  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single session row with date, status icon, and colored text.
  Widget _buildSessionTile(BuildContext context, dynamic session) {
    final String status = session['status'] ?? 'missing';
    final String colKey = session['col_key'] ?? '';

    // Extract readable date from col_key (format: postId_YYYY-MM-DD)
    String dateLabel = 'Unknown date';
    if (colKey.contains('_')) {
      final parts = colKey.split('_');
      if (parts.length >= 2) {
        dateLabel = parts.sublist(1).join('_');
      }
    }

    final IconData icon;
    final Color statusColor;
    final String statusText;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case 'rejected':
        icon = Icons.cancel;
        statusColor = AppColors.danger;
        statusText = 'Rejected';
        break;
      case 'missing':
        icon = Icons.highlight_off;
        statusColor = AppColors.danger;
        statusText = 'Missing';
        break;
      case 'pending':
        icon = Icons.access_time;
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      default:
        icon = Icons.help_outline;
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    final bool isExcuse = session['is_excuse'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (isExcuse)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Excuse submitted',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade300,
                            fontSize: 11,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _complianceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 50) return Colors.orange;
    return AppColors.danger;
  }
}
