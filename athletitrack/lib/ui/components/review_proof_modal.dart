import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'video_player_widget.dart';
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
    final submittedAt = (widget.statusObj['submitted_at'] ?? '').toString();

    
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
    // file_url can arrive as a JSON string or an already-decoded List
    final rawValue = widget.statusObj['file_url'];
    if (rawValue is List) {
      files = rawValue.map((e) => e.toString()).toList();
    } else if (rawValue is String && rawValue.isNotEmpty && rawValue != '[]') {
      try {
        final decoded = jsonDecode(rawValue);
        if (decoded is List) {
          files = decoded.map((e) => e.toString()).toList();
        } else if (decoded is String) {
          files = [decoded];
        }
      } catch (_) {
        files = [rawValue];
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
                    final uri = Uri.tryParse(file);
                    // Strip query params before extracting extension
                    final pathOnly = uri?.path ?? file;
                    final lastSegment = pathOnly.split('/').last;
                    final ext = lastSegment.contains('.') ? lastSegment.split('.').last.toLowerCase() : '';
                    
                    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext) || file.startsWith('data:image');
                    final isVideo = ['mp4', 'mov', 'avi', 'webm'].contains(ext) || file.startsWith('data:video');
                    final isPdf = ext == 'pdf' || file.startsWith('data:application/pdf');
                    final isDoc = ['doc', 'docx'].contains(ext);
                    
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        if (isImage) {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(32),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: Colors.black87,
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: InteractiveViewer(
                                          panEnabled: true,
                                          minScale: 0.5,
                                          maxScale: 4.0,
                                          child: Image.network(file, fit: BoxFit.contain),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: SafeArea(
                                          child: Material(
                                            color: Colors.black54,
                                            shape: const CircleBorder(),
                                            child: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.white, size: 24),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  )
                                )
                              )
                            )
                          );
                        } else if (isVideo) {
                          if (kIsWeb) {
                            // Web: open video directly in browser for better compatibility
                            try {
                              await launchUrl(Uri.parse(file), mode: LaunchMode.platformDefault);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open video.'), backgroundColor: AppColors.danger),
                                );
                              }
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(32),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: Colors.black,
                                    width: double.maxFinite,
                                    height: double.maxFinite,
                                    child: Stack(
                                      children: [
                                        Center(child: VideoPlayerWidget(url: file)),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: SafeArea(
                                            child: Material(
                                              color: Colors.black54,
                                              shape: const CircleBorder(),
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    )
                                  )
                                )
                              )
                            );
                          }
                        } else if (isPdf) {
                          if (kIsWeb) {
                            // Web: open PDF directly in browser — most reliable approach
                            try {
                              await launchUrl(Uri.parse(file), mode: LaunchMode.platformDefault);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open PDF.'), backgroundColor: AppColors.danger),
                                );
                              }
                            }
                          } else {
                            // Mobile: use SfPdfViewer with Google Docs fallback
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(32),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: AppColors.background,
                                    width: double.maxFinite,
                                    height: double.maxFinite,
                                    child: Stack(
                                      children: [
                                        SfPdfViewer.network(
                                          file,
                                          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                                            if (mounted) {
                                              Navigator.pop(context);
                                              // Fallback: open in external viewer
                                              _openInExternalViewer(file);
                                            }
                                          },
                                        ),
                                        Positioned(
                                          left: 8,
                                          top: 8,
                                          child: SafeArea(
                                            child: Material(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(8),
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(8),
                                                onTap: () => _openInExternalViewer(file),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.open_in_browser, color: Colors.white, size: 20),
                                                      SizedBox(width: 8),
                                                      Text('Open in Browser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: SafeArea(
                                            child: Material(
                                              color: Colors.black54,
                                              shape: const CircleBorder(),
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    )
                                  )
                                )
                              )
                            );
                          }
                        } else {
                          // DOCX/DOC/other files: use Google Docs Viewer or direct open
                          await _openInExternalViewer(file);
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
                                    Icon(
                                      isVideo ? Icons.play_circle_outline 
                                        : isPdf ? Icons.picture_as_pdf 
                                        : isDoc ? Icons.description 
                                        : Icons.insert_drive_file, 
                                      size: 32, 
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        _getFileName(file),
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
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (status != 'rejected') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showRejectNote = true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.danger),
                        foregroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                if (status != 'approved') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('approved'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
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

  /// Opens a file URL using Google Docs Viewer (for DOCX/DOC/PDF) or direct browser
  Future<void> _openInExternalViewer(String fileUrl) async {
    try {
      final viewerUrl = 'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(fileUrl)}';
      final uri = Uri.parse(viewerUrl);
      
      if (kIsWeb) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          // Fallback: try opening the raw URL directly
          await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.platformDefault);
        }
      } else {
        // Mobile: try in-app browser, then external
        if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            // Last resort: open raw URL
            await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open file. Try downloading it directly.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Extracts a clean file name from a Supabase storage URL
  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
      // Remove the UUID prefix (e.g., "6684a1c2e4f5a_")
      final underscoreIndex = pathSegment.indexOf('_');
      if (underscoreIndex > 0 && underscoreIndex < pathSegment.length - 1) {
        return pathSegment.substring(underscoreIndex + 1);
      }
      return pathSegment;
    } catch (_) {
      return url.split('/').last;
    }
  }
}
