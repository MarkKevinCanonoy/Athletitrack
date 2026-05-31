<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");
$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['post_id']) || empty($inputData['title'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (post_id, title).']);
    exit();
}

$post_id = $inputData['post_id'];
$updateData = [
    'type' => $inputData['type'] ?? 'training',
    'title' => $inputData['title'],
    'content' => $inputData['content'] ?? null,
    'session_date' => $inputData['session_date'] ?? null,
    'session_time' => $inputData['session_time'] ?? null,
    'is_weekly' => isset($inputData['is_weekly']) ? filter_var($inputData['is_weekly'], FILTER_VALIDATE_BOOLEAN) : false,
    'days_of_week' => $inputData['days_of_week'] ?? null
];

$response = supabase_request("/rest/v1/posts?id=eq." . urlencode($post_id), 'PATCH', $updateData);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Post updated successfully.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to update post.', 'details' => $response['data']]);
}
?>
