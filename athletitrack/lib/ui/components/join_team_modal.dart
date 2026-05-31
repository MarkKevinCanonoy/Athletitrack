import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/requests_provider.dart';

class JoinTeamModal extends ConsumerStatefulWidget {
  const JoinTeamModal({super.key});

  @override
  ConsumerState<JoinTeamModal> createState() => _JoinTeamModalState();
}

class _JoinTeamModalState extends ConsumerState<JoinTeamModal> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final reqsState = ref.watch(requestsProvider);

    return AppCard(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350), margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Join Team', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ask your coach for the team code, then enter it here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Team Code',
                hintText: 'e.g. TEAM-ABC12',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            if (reqsState.error != null) ...[
              Text(reqsState.error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: reqsState.isLoading ? null : () async {
                final code = _codeController.text.trim();
                if (code.isEmpty) return;

                final success = await ref.read(requestsProvider.notifier).joinTeam(code);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Join request sent to coach!'))
                  );
                  Navigator.pop(context); // Close modal
                }
              },
              child: reqsState.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Join'),
            )
          ],
        ),
      ),
    );
  }
}
