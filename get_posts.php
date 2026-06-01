<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['team_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required field: team_id.']);
    exit();
}

$team_id = $inputData['team_id'];
$user_id = $inputData['user_id'] ?? null;
$role = $inputData['role'] ?? null;

// Fetch posts for the given team, ordered by created_at descending
$response = supabase_request("/rest/v1/posts?team_id=eq." . urlencode($team_id) . "&order=created_at.desc", 'GET');

if ($response['status'] == 200) {
    $posts = $response['data'];
    
    // Skill Level Filtering (FR-20)
    if ($role === 'Athlete' && $user_id) {
        // Fetch athlete's skill level
        $memberResp = supabase_request("/rest/v1/team_members?team_id=eq." . urlencode($team_id) . "&athlete_id=eq." . urlencode($user_id), 'GET');
        $athlete_skill = 'Intermediate'; // Default
        if ($memberResp['status'] == 200 && !empty($memberResp['data'])) {
            $athlete_skill = $memberResp['data'][0]['skill_level'] ?? 'Intermediate';
        }

        $filteredPosts = [];
        foreach ($posts as $post) {
            $post_skill = $post['target_skill_level'] ?? 'All';
            if ($post_skill === 'All' || empty($post_skill) || strtolower($post_skill) === strtolower($athlete_skill)) {
                $filteredPosts[] = $post;
            }
        }
        $posts = $filteredPosts;
    }

    echo json_encode(['status' => 'success', 'posts' => $posts]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to fetch posts.', 'details' => $response['data']]);
}
?>
