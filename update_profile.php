<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['user_id']) || empty($inputData['full_name'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing user_id or full_name.']);
    exit();
}

$user_id = $inputData['user_id'];
$full_name = $inputData['full_name'];

$response = supabase_request("/rest/v1/users?id=eq." . urlencode($user_id), 'PATCH', ['full_name' => $full_name]);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to update profile.', 'details' => $response['data']]);
}
?>
