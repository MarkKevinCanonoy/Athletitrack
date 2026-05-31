<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");
$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['post_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing post_id.']);
    exit();
}

$post_id = $inputData['post_id'];
$response = supabase_request("/rest/v1/posts?id=eq." . urlencode($post_id), 'DELETE');

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Post deleted successfully.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete post.']);
}
?>
