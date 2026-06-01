import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../providers/posts_provider.dart';

class OfflineSyncService {
  static const String _feedBoxName = 'feedCache';
  static const String _teamsBoxName = 'teamsCache';
  static const String _queueBoxName = 'offlineUploadQueue';
  static const String _attendanceBoxName = 'attendanceCache';

  Future<void> init() async {
    await Hive.initFlutter();
    
    await Hive.openBox(_feedBoxName);
    await Hive.openBox(_teamsBoxName);
    await Hive.openBox(_queueBoxName);
    await Hive.openBox(_attendanceBoxName);
  }

  // --- Caching ---

  Future<void> cacheData(String boxName, String key, dynamic data) async {
    final box = Hive.box(boxName);
    await box.put(key, {
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  Map<String, dynamic>? getCachedData(String boxName, String key) {
    final box = Hive.box(boxName);
    final cached = box.get(key);
    if (cached != null) {
      return Map<String, dynamic>.from(cached);
    }
    return null;
  }

  // Convenience methods
  Future<void> cacheTeamFeed(String teamId, List<Map<String, dynamic>> posts) => cacheData(_feedBoxName, teamId, posts);
  Map<String, dynamic>? getCachedTeamFeed(String teamId) => getCachedData(_feedBoxName, teamId);

  Future<void> cacheTeams(String userId, List<Map<String, dynamic>> teams) => cacheData(_teamsBoxName, userId, teams);
  Map<String, dynamic>? getCachedTeams(String userId) => getCachedData(_teamsBoxName, userId);

  Future<void> cacheAttendance(String teamId, Map<String, dynamic> attendanceData) => cacheData(_attendanceBoxName, teamId, attendanceData);
  Map<String, dynamic>? getCachedAttendance(String teamId) => getCachedData(_attendanceBoxName, teamId);

  // --- Offline Write Queue for Uploads ---

  Future<void> queueUpload(Map<String, dynamic> task) async {
    final box = Hive.box(_queueBoxName);
    await box.put(task['id'], task);
  }

  List<Map<String, dynamic>> getPendingUploads() {
    final box = Hive.box(_queueBoxName);
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  Future<void> removeUpload(String taskId) async {
    final box = Hive.box(_queueBoxName);
    await box.delete(taskId);
  }

  /// Called periodically or when network status changes to online
  Future<void> syncPendingUploads(Ref ref) async {
    final pending = getPendingUploads();
    if (pending.isEmpty) return;
    
    for (final task in pending) {
      try {
        bool success = false;
        if (task['type'] == 'submitProof') {
          success = await ref.read(attendanceProvider.notifier).submitProof(
            postId: task['postId'],
            userId: task['userId'],
            files: [], // Empty files for offline queued items
            message: task['message'] ?? '',
            teamId: task['teamId'],
            isExcuse: task['isExcuse'] ?? false,
          );
        } else if (task['type'] == 'createPost') {
          success = await ref.read(postsProvider.notifier).createPost(
            teamId: task['teamId'],
            type: task['postType'],
            title: task['title'],
            content: task['content'],
            sessionDate: task['sessionDate'],
            sessionTime: task['sessionTime'],
            isWeekly: task['isWeekly'] ?? false,
            daysOfWeek: task['daysOfWeek'],
            targetSkillLevel: task['targetSkillLevel'] ?? 'All',
          );
        }

        if (success) {
          await removeUpload(task['id']);
          print("Successfully synced task: ${task['id']}");
        }
      } catch (e) {
        print("Failed to sync task: ${task['id']}, will retry later.");
      }
    }
  }
}

// Update the provider to pass ref if needed, but it's simpler to just accept notifiers in syncPendingUploads.
final offlineSyncProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService();
});

