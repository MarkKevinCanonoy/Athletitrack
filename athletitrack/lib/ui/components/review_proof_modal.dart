import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/providers/attendance_provider.dart';

class ReviewProofModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> statusObj;
  final String teamId;
  final String athleteName;

  const ReviewProofModal({
    super.key,
    required this.statusObj,
    required this.teamId,
    required this.athleteName,
  });

  @override
  ConsumerState<ReviewProofModal> createState() => _ReviewProofModalState();
}

class _ReviewProofModalState extends ConsumerState<ReviewProofModal> {
  bool _isSubmitting = false;
  bool _showRejectNote = false;
  final _rejectNoteController = TextEditingController();

  @override
  void dispose() {
    _rejectNoteController.dispose();
    super.dispose();
  }

  void _updateStatus(String newStatus) async {
    setState(() => _isSubmitting = true);
    
    final success = await ref
        .read(attendanceProvider.notifier)
        .updateProofStatus(
          widget.statusObj['proof_id'], 
          widget.teamId, 
          newStatus,
          coachNote: newStatus == 'rejected' ? _rejectNoteController.text.trim() : null,
        );
    
    setState(() => _isSubmitting = false);
    
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.statusObj['status'];
    final isExcuse = widget.statusObj['is_excuse'] ?? false;
    final comment = widget.statusObj['comment'] ?? '';
    final coachNote = widget.statusObj['coach_note'] ?? '';
    final submittedAt = widget.statusObj['submitted_at'] ?? '';
    final fileUrlRaw = widget.statusObj['file_url'] ?? '[]';
    
    // Format the timestamp if available
    String formattedTime = '';
    if (submittedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(submittedAt).toLocal();
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final min = dt.minute.toString().padLeft(2, '0');
        formattedTime = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} at $hour:$min $ampm';
      } catch (_) {
        formattedTime = submittedAt;
      }
    }
    
    List<String> files = [];
    try {
      final decoded = jsonDecode(fileUrlRaw);
      if (decoded is List) {
        files = decoded.cast<String>();
      } else if (decoded is String) {
        files = [decoded];
      }
    } catch (_) {
      if (fileUrlRaw.isNotEmpty && fileUrlRaw != '[]') {
        files = [fileUrlRaw];
      }
    }

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              widget.athleteName.isNotEmpty ? widget.athleteName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.athleteName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                      ),
                      child: Text(
                        status.toString().toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (isExcuse) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'EXCUSE',
                          style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                if (formattedTime.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Submitted: $formattedTime',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Excuse warning banner
              if (isExcuse)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is an excuse submission. Please review carefully.',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Athlete message
              if (comment.isNotEmpty) ...[
                const Text('ATHLETE MESSAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(comment, style: const TextStyle(color: Colors.white, height: 1.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Existing coach note (if already rejected)
              if (coachNote != null && coachNote.toString().isNotEmpty) ...[
                const Text('COACH NOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note_alt_outlined, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(coachNote.toString(), style: const TextStyle(color: AppColors.danger, height: 1.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Attachments
              const Text('ATTACHMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 8),
              if (files.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attachment_outlined, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 8),
                      Text('No files attached', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: files.map((file) {
                    final ext = file.split('.').last.toLowerCase();
                    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext) || file.startsWith('data:image') || file.contains('image');
                    
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (isImage) {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(file, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ]
                              )
                            )
                          );
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isImage
                            ? Image.network(file, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: AppColors.textSecondary)))
                            : Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.insert_drive_file, size: 32, color: AppColors.primary),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        file.split('/').last,
                                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
              
              // Rejection note input (shown when coach clicks Reject)
              if (_showRejectNote) ...[
                const SizedBox(height: 20),
                const Text('REJECTION NOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger, letterSpacing: 1)),
                const SizedBox(height: 8),
                TextField(
                  controller: _rejectNoteController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Explain why this proof is rejected or assign corrective action...',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.danger),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showRejectNote = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () => _updateStatus('rejected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isSubmitting 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send, size: 16),
                        label: const Text('Confirm Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: _showRejectNote ? null : [
        if (_isSubmitting)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircularProgressIndicator(),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          if (status != 'rejected')
            OutlinedButton.icon(
              onPressed: () => setState(() => _showRejectNote = true),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                foregroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Reject'),
            ),
          if (status != 'approved')
            ElevatedButton.icon(
              onPressed: () => _updateStatus('approved'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Approve'),
            ),
        ]
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.danger;
      case 'pending': return Colors.orange;
      default: return AppColors.textSecondary;
    }
  }
}
