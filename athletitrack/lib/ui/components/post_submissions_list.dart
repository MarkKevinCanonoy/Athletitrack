import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/services/api_client.dart';
import 'review_proof_modal.dart';
import '../utils/modal_utils.dart';

class PostSubmissionsList extends StatefulWidget {
  final String teamId;
  final String postId;

  const PostSubmissionsList({super.key, required this.teamId, required this.postId});

  @override
  State<PostSubmissionsList> createState() => _PostSubmissionsListState();
}

class _PostSubmissionsListState extends State<PostSubmissionsList> {
  List<dynamic> _submissions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    try {
      final response = await ApiClient().dio.post(
        '/get_post_submissions.php',
        data: {'team_id': widget.teamId, 'post_id': widget.postId},
      );

      final data = response.data;
      if (data['status'] == 'success') {
        if (mounted) {
          setState(() {
            _submissions = data['submissions'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to load submissions');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.danger;
      case 'pending': return Colors.orange;
      default: return AppColors.textSecondary.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text('Error: $_error', style: const TextStyle(color: AppColors.danger)),
      );
    }

    if (_submissions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('No athletes in this team.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            'Athlete Submissions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _submissions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final sub = _submissions[index];
            final status = sub['status'] as String;
            final isMissing = status == 'missing';
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              title: Text(sub['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: isMissing ? null : () {
                final proof = sub['proof'] as Map<String, dynamic>? ?? {};
                final statusObj = {
                  'status': status,
                  'proof_id': proof['id'],
                  'file_url': proof['file_url'],
                  'is_excuse': proof['is_excuse'] == true || proof['is_excuse'] == 'true' || proof['is_excuse'] == 1,
                  'comment': proof['comment'],
                };
                showDialog(
                  context: context,
                  builder: (_) => ReviewProofModal(
                    statusObj: statusObj,
                    teamId: widget.teamId,
                    athleteName: sub['name'],
                  ),
                ).then((_) {
                  // Refresh after review
                  setState(() { _isLoading = true; });
                  _fetchSubmissions();
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
