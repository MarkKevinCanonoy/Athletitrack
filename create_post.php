<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['team_id']) || empty($inputData['type']) || empty($inputData['title'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (team_id, type, title).']);
    exit();
}

$team_id = $inputData['team_id'];
$type = $inputData['type'];
$title = $inputData['title'];
$content = $inputData['content'] ?? null;
$session_date = $inputData['session_date'] ?? null;
$session_time = $inputData['session_time'] ?? null;
$is_weekly = isset($inputData['is_weekly']) ? filter_var($inputData['is_weekly'], FILTER_VALIDATE_BOOLEAN) : false;
$days_of_week = $inputData['days_of_week'] ?? null;
$target_skill_level = $inputData['target_skill_level'] ?? 'All';

$insertData = [
    'team_id' => $team_id,
    'type' => $type,
    'title' => $title,
    'content' => $content,
    'session_date' => $session_date,
    'session_time' => $session_time,
    'is_weekly' => $is_weekly,
    'days_of_week' => $days_of_week,
    'target_skill_level' => $target_skill_level
];

$response = supabase_request("/rest/v1/posts", 'POST', $insertData);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Post created successfully.', 'post' => $response['data'][0] ?? $response['data']]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to create post.', 'details' => $response['data']]);
}
?>
