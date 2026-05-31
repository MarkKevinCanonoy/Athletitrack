import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'common_components.dart';
import '../../core/providers/auth_provider.dart';

class ProfileModal extends ConsumerStatefulWidget {
  const ProfileModal({super.key});

  @override
  ConsumerState<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends ConsumerState<ProfileModal> {
  bool isEditing = false;
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    nameController = TextEditingController(text: user?['full_name'] ?? 'AthletiTrack User');
    emailController = TextEditingController(text: user?['email'] ?? 'user@athletitrack.com');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
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
                Text(isEditing ? 'Edit Profile' : 'Profile', style: Theme.of(context).textTheme.displaySmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 60, color: AppColors.primary),
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isEditing) ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                readOnly: true,
                style: const TextStyle(color: AppColors.textSecondary),
                decoration: const InputDecoration(
                  labelText: 'Email Address (Cannot be changed)',
                  filled: true,
                  fillColor: Colors.black12,
                ),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge, color: AppColors.textSecondary),
                title: Text('Name', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                subtitle: Text(nameController.text, style: Theme.of(context).textTheme.bodyMedium),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email, color: AppColors.textSecondary),
                title: Text('Email', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                subtitle: Text(emailController.text, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
            const SizedBox(height: 24),
            if (isEditing)
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name cannot be empty')),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (ctx) => AppDialog(
                      title: 'Save Profile',
                      content: 'Are you sure you want to save these changes?',
                      icon: Icons.save,
                      confirmText: 'Save Changes',
                      onConfirm: () async {
                        Navigator.pop(ctx); // Close dialog
                        
                        final success = await ref.read(authProvider.notifier).updateProfile(nameController.text.trim());
                        
                        if (success && mounted) {
                          setState(() => isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully!'))
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update profile'))
                          );
                        }
                      },
                    ),
                  );
                },
                child: const Text('Save Changes'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => setState(() => isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              )
          ],
        ),
      ),
    );
  }
}
