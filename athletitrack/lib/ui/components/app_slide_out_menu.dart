import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';

import 'profile_modal.dart';
import 'about_modal.dart';
import '../utils/modal_utils.dart';
import 'common_components.dart';

class AppSlideOutMenu extends ConsumerWidget {
  const AppSlideOutMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'AthletiTrack',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(context, icon: Icons.person, title: 'Profile', onTap: () {
            Navigator.pop(context); // close drawer first
            ModalUtils.showCustomModal(context: context, builder: (_) => const ProfileModal());
          }),
          _buildMenuItem(context, icon: Icons.info_outline, title: 'About', onTap: () {
            Navigator.pop(context); // close drawer first
            ModalUtils.showCustomModal(context: context, builder: (_) => const AboutModal());
          }),
          const Divider(color: AppColors.border),
          _buildMenuItem(context, icon: Icons.logout, title: 'Logout', onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AppDialog(
                title: 'Log Out',
                content: 'Are you sure you want to log out?',
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                confirmText: 'Log out',
                confirmColor: Colors.redAccent,
                onConfirm: () {
                  Navigator.pop(ctx); // Close dialog
                  ref.read(authProvider.notifier).logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully logged out.')),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}
