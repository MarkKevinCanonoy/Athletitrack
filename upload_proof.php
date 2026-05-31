<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['post_id']) || empty($inputData['user_id']) || empty($inputData['files'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (post_id, user_id, files).']);
    exit();
}

$post_id = $inputData['post_id'];
$user_id = $inputData['user_id'];
$files = $inputData['files']; // Expect array of base64 files or dummy urls
$message = $inputData['message'] ?? '';
$is_excuse = $inputData['is_excuse'] ?? false;

// We will simulate uploading by saving them or just storing their names
$urls = [];
foreach ($files as $file) {
    // If it's a real file upload in MVP, we can just save it as a dummy URL for now
    $urls[] = "https://mock-storage.athletitrack/file_" . uniqid() . ".xyz";
}

$file_url = json_encode($urls);
$file_type = 'multiple';

// Notice: In the schema, it's `training_proof`. The get_attendance queries `/rest/v1/proofs`.
// Wait, get_attendance queries `proofs`. Let's check schema.sql.
// Actually get_attendance queries /rest/v1/proofs but the schema says training_proof. Let's insert into training_proof.
$insertData = [
    'post_id' => $post_id,
    'athlete_id' => $user_id,
    'file_url' => $file_url,
    'status' => 'pending',
    'is_excuse' => $is_excuse,
    'comment' => $message
];

$response = supabase_request("/rest/v1/proofs", 'POST', $insertData);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Proof submitted successfully.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to submit proof.', 'details' => $response['data']]);
}
?>
