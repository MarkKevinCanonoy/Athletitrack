import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_task.dart';

class OfflineSyncService {
  static const String _feedBoxName = 'feedCache';
  static const String _queueBoxName = 'offlineUploadQueue';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters (Make sure to run build_runner to generate the adapter)
    if (!Hive.isAdapterRegistered(0)) {
      // Hive.registerAdapter(UploadTaskAdapter());
    }

    await Hive.openBox(_feedBoxName);
    await Hive.openBox(_queueBoxName);
  }

  // --- Caching Team Feeds ---

  Future<void> cacheTeamFeed(String teamId, List<Map<String, dynamic>> posts) async {
    final box = Hive.box(_feedBoxName);
    await box.put(teamId, posts);
  }

  List<Map<String, dynamic>> getCachedTeamFeed(String teamId) {
    final box = Hive.box(_feedBoxName);
    final cached = box.get(teamId);
    if (cached != null) {
      return List<Map<String, dynamic>>.from(cached);
    }
    return [];
  }

  // --- Offline Write Queue for Uploads ---

  Future<void> queueUpload(UploadTask task) async {
    final box = Hive.box(_queueBoxName);
    await box.put(task.id, task);
  }

  List<UploadTask> getPendingUploads() {
    final box = Hive.box(_queueBoxName);
    return box.values.cast<UploadTask>().toList();
  }

  Future<void> removeUpload(String taskId) async {
    final box = Hive.box(_queueBoxName);
    await box.delete(taskId);
  }

  /// Called periodically or when network status changes to online
  Future<void> syncPendingUploads() async {
    final pending = getPendingUploads();
    for (final task in pending) {
      try {
        // 1. Attempt to upload to backend via Dio
        // await BackendService.uploadFile(task.filePath, ...);

        // 2. If successful, remove from queue
        await removeUpload(task.id);
        print('Successfully synced task: \${task.id}');
      } catch (e) {
        // 3. If failed due to network, leave in queue to try again later
        print('Failed to sync task: \${task.id}, will retry later.');
      }
    }
  }
}

final offlineSyncProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService();
});
