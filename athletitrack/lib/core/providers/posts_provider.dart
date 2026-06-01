import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';
import '../services/offline_sync_service.dart';
import 'network_provider.dart';

class PostsState {
  final List<Map<String, dynamic>> posts;
  final bool isLoading;
  final String? error;

  PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostsState copyWith({
    List<Map<String, dynamic>>? posts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier(this.ref) : super(PostsState());
  
  final Ref ref;
  final _api = ApiClient();

  Future<void> fetchPosts(String teamId, {String? userId, String? role}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final isOnline = ref.read(networkProvider);
    if (!isOnline) {
      final cached = ref.read(offlineSyncProvider).getCachedTeamFeed(teamId);
      if (cached != null) {
        final List<dynamic> rawPosts = cached['data'] ?? [];
        state = state.copyWith(isLoading: false, posts: rawPosts.cast<Map<String, dynamic>>());
      } else {
        state = state.copyWith(isLoading: false, error: 'No offline data available for posts');
      }
      return;
    }

    try {
      final response = await _api.dio.post('/get_posts.php', data: {
        'team_id': teamId,
        if (userId != null) 'user_id': userId,
        if (role != null) 'role': role,
      });

      if (response.data['status'] == 'success') {
        final List<dynamic> rawPosts = response.data['posts'] ?? [];
        final List<Map<String, dynamic>> postsList = rawPosts.cast<Map<String, dynamic>>();
        
        ref.read(offlineSyncProvider).cacheTeamFeed(teamId, postsList);
        
        state = state.copyWith(isLoading: false, posts: postsList);
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to fetch posts: ${e.toString()}');
    }
  }

  Future<bool> createPost({
    required String teamId,
    required String type,
    required String title,
    String? content,
    String? sessionDate,
    String? sessionTime,
    bool isWeekly = false,
    String? daysOfWeek,
    String targetSkillLevel = 'All',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final isOnline = ref.read(networkProvider);
    if (!isOnline) {
      // In a real robust app, we'd add it to a local list immediately so it shows up
      // For now we'll just queue it for sync
      final syncService = ref.read(offlineSyncProvider);
      final taskId = 'post_${DateTime.now().millisecondsSinceEpoch}';
      
      await syncService.queueUpload({
        'id': taskId,
        'type': 'createPost',
        'teamId': teamId,
        'postType': type,
        'title': title,
        'content': content,
        'sessionDate': sessionDate,
        'sessionTime': sessionTime,
        'isWeekly': isWeekly,
        'daysOfWeek': daysOfWeek,
        'targetSkillLevel': targetSkillLevel,
      });
      
      state = state.copyWith(isLoading: false);
      return true; // Pretend it succeeded
    }

    try {
      final response = await _api.dio.post('/create_post.php', data: {
        'team_id': teamId,
        'type': type,
        'title': title,
        'content': content,
        'session_date': sessionDate,
        'session_time': sessionTime,
        'is_weekly': isWeekly,
        'days_of_week': daysOfWeek,
        'target_skill_level': targetSkillLevel,
      });

      if (response.data['status'] == 'success') {
        await fetchPosts(teamId);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create post: ${e.toString()}');
      return false;
    }
  }

  Future<bool> editPost({
    required String teamId,
    required String postId,
    required String type,
    required String title,
    String? content,
    String? sessionDate,
    String? sessionTime,
    bool isWeekly = false,
    String? daysOfWeek,
    String targetSkillLevel = 'All',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/edit_post.php', data: {
        'post_id': postId,
        'type': type,
        'title': title,
        'content': content,
        'session_date': sessionDate,
        'session_time': sessionTime,
        'is_weekly': isWeekly,
        'days_of_week': daysOfWeek,
        'target_skill_level': targetSkillLevel,
      });

      if (response.data['status'] == 'success') {
        await fetchPosts(teamId);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to edit post: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deletePost(String teamId, String postId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/delete_post.php', data: {
        'post_id': postId,
      });

      if (response.data['status'] == 'success') {
        await fetchPosts(teamId);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete post: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier(ref);
});
