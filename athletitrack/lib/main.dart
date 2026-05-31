import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'core/router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/network_provider.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/notification_service.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive Offline Storage
  final offlineSyncService = OfflineSyncService();
  await offlineSyncService.init();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    const ProviderScope(
      child: AthletiTrackApp(),
    ),
  );
}

class AthletiTrackApp extends ConsumerWidget {
  const AthletiTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AthletiTrack',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final isOnline = ref.watch(networkProvider);
        return Stack(
          children: [
            if (child != null) child,
            if (!isOnline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  color: AppColors.danger,
                  elevation: 4,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'You are currently offline. Viewing cached data.',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
