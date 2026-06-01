import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_client.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/network_provider.dart';
import '../../core/services/offline_sync_service.dart';

class UploadProofModal extends ConsumerStatefulWidget {
  final bool isExcuse;
  final Map<String, dynamic> post;
  final String teamId;

  const UploadProofModal({super.key, this.isExcuse = false, required this.post, required this.teamId});

  @override
  ConsumerState<UploadProofModal> createState() => _UploadProofModalState();
}

class _UploadProofModalState extends ConsumerState<UploadProofModal> {
  List<dynamic> attachedFiles = [];
  final _messageController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  double? _uploadProgress;
  Map<String, dynamic>? _existingProof;

  @override
  void initState() {
    super.initState();
    _checkExistingProof();
  }

  Future<void> _checkExistingProof() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    try {
      final res = await ApiClient().dio.post('/check_proof_status.php', data: {
        'user_id': user['id'],
        'post_id': widget.post['id'],
      });
      if (res.data['status'] == 'success' && res.data['proof'] != null) {
        setState(() {
          _existingProof = res.data['proof'];
        });
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} at $hour:$min $ampm';
    } catch (_) {
      return timestamp;
    }
  }

  Future<void> _pickFiles() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'mp4', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          attachedFiles.addAll(result.files);
        });
      }
    } else {
      // Mobile - show bottom sheet for options
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (file != null) setState(() => attachedFiles.add(file));
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final file = await picker.pickVideo(source: ImageSource.camera);
                  if (file != null) setState(() => attachedFiles.add(file));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final files = await picker.pickMultiImage(imageQuality: 70);
                  if (files.isNotEmpty) setState(() => attachedFiles.addAll(files));
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Upload Document'),
                onTap: () async {
                  Navigator.pop(ctx);
                  FilePickerResult? result = await FilePicker.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );
                  if (result != null) setState(() => attachedFiles.addAll(result.files));
                },
              ),
            ],
          ),
        )
      );
    }
  }

  Future<void> _submit() async {
    if (attachedFiles.isEmpty && !widget.isExcuse) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one file.')));
      return;
    }
    
    // Check total size
    int totalBytes = 0;
    for (var f in attachedFiles) {
      if (f is PlatformFile) {
        if (f.size > 0) totalBytes += f.size;
      } else if (f is XFile) {
        final length = await f.length();
        totalBytes += length;
      }
    }
    
    if (totalBytes > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total file size exceeds 10MB limit. Please remove some files or compress them.')));
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _uploadProgress = null;
    });
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isOnline = ref.read(networkProvider);
    if (!isOnline) {
      // Save to offline queue
      final task = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'postId': widget.post['id'].toString(),
        'userId': user['id'].toString(),
        'message': _messageController.text,
        'teamId': widget.teamId,
        'isExcuse': widget.isExcuse,
      };
      await ref.read(offlineSyncProvider).queueUpload(task);
      setState(() => _isSubmitting = false);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline: Proof queued for sync later.')));
      }
      return;
    }

    final success = await ref.read(attendanceProvider.notifier).submitProof(
      postId: widget.post['id'].toString(),
      userId: user['id'].toString(),
      files: attachedFiles,
      message: _messageController.text,
      teamId: widget.teamId,
      isExcuse: widget.isExcuse,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _uploadProgress = progress;
          });
        }
      },
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted successfully!')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(attendanceProvider).error ?? 'Submission failed.')),
      );
    }
  }

  Future<void> _unsubmit() async {
    if (_existingProof == null) return;
    setState(() => _isSubmitting = true);

    final success = await ref.read(attendanceProvider.notifier).unsubmitProof(
      _existingProof!['id'].toString(),
      widget.teamId,
    );

    if (success && mounted) {
      setState(() {
        _existingProof = null;
        _isSubmitting = false;
        attachedFiles = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unsubmitted successfully!')));
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppCard(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.isExcuse ? 'Submit Excuse' : 'Upload Proof', 
                     style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            if (_existingProof != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                    const SizedBox(height: 8),
                    const Text('You have already submitted proof.', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Status: ${_existingProof!['status']}', style: const TextStyle(color: AppColors.textSecondary)),
                    if (_existingProof!['submitted_at'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Submitted on: ${_formatTimestamp(_existingProof!['submitted_at'])}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _unsubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                icon: const Icon(Icons.undo),
                label: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Unsubmit'),
              ),
            ] else ...[
              if (!widget.isExcuse)
                Text(
                  'Upload a photo, video, or document proving you completed this session.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Text(
                  'Upload a valid excuse document (e.g., medical certificate) and explain below.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: Text(attachedFiles.isNotEmpty ? '${attachedFiles.length} file(s) selected' : 'Select Files'),
              ),
              if (attachedFiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: attachedFiles.map((f) => Chip(
                    label: Text(f.name, style: const TextStyle(fontSize: 12)),
                    onDeleted: () {
                      setState(() {
                        attachedFiles.remove(f);
                      });
                    },
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Optional Message / Explanation'),
                maxLines: 3,
              ),
              if (_isSubmitting) ...[
                if (_uploadProgress != null) ...[
                  LinearProgressIndicator(value: _uploadProgress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  Text('${(_uploadProgress! * 100).toInt()}% Uploaded', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ] else ...[
                  const Center(child: CircularProgressIndicator()),
                ],
              ] else ...[
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.isExcuse ? 'Submit Excuse' : 'Mark as Done'),
                )
              ]
            ],
          ],
        ),
      ),
    );
  }
}
