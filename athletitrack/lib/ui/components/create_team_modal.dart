import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/teams_provider.dart';

class CreateTeamModal extends ConsumerStatefulWidget {
  const CreateTeamModal({super.key});

  @override
  ConsumerState<CreateTeamModal> createState() => _CreateTeamModalState();
}

class _CreateTeamModalState extends ConsumerState<CreateTeamModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String selectedSkill = 'Beginner';
  String generatedCode = '';

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _generateCode() {
    setState(() {
      // Basic unique alphanumeric code generation logic
      generatedCode = 'TEAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Create New Team', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Team Name')
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category (e.g., Men\'s, College)')
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSkill,
              decoration: const InputDecoration(labelText: 'Skill Level'),
              items: ['Beginner', 'Intermediate', 'Expert']
                  .map((skill) => DropdownMenuItem(value: skill, child: Text(skill)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedSkill = val);
              },
              dropdownColor: AppColors.surface,
            ),
            const SizedBox(height: 24),
            if (generatedCode.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  children: [
                    const Text('Share this code with athletes:', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    SelectableText(
                      generatedCode, 
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 4,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                if (generatedCode.isEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _generateCode,
                      child: const Text('Generate Code'),
                    ),
                  ),
                if (generatedCode.isNotEmpty)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AppDialog(
                            title: 'Save Team',
                            content: 'Are you sure you want to create this team?',
                            icon: Icons.group_add,
                            confirmText: 'Create Team',
                            onConfirm: () async {
                              Navigator.pop(ctx); // Close dialog
                              
                              final name = _nameController.text.trim();
                              final category = _categoryController.text.trim();
                              
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a team name.')),
                                );
                                return;
                              }
                              
                              final success = await ref.read(teamsProvider.notifier).createTeam(
                                name, category, selectedSkill, generatedCode
                              );
                              
                              if (success && mounted) {
                                Navigator.pop(context); // Close modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Team successfully created!')),
                                );
                              } else if (mounted) {
                                final error = ref.read(teamsProvider).error ?? 'Failed to create team';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
                                );
                              }
                            },
                          ),
                        );
                      },
                      child: const Text('Save Team'),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
