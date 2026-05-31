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

// Fetch posts for the given team, ordered by created_at descending
$response = supabase_request("/rest/v1/posts?team_id=eq." . urlencode($team_id) . "&order=created_at.desc", 'GET');

if ($response['status'] == 200) {
    echo json_encode(['status' => 'success', 'posts' => $response['data']]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to fetch posts.', 'details' => $response['data']]);
}
?>
