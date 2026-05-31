<?php
require_once 'config.php';
require_once 'debug_helper.php';
header("Content-Type: application/json; charset=UTF-8");

$post_id = $_POST['post_id'] ?? '';
$user_id = $_POST['user_id'] ?? '';
$message = $_POST['message'] ?? '';
$is_excuse = isset($_POST['is_excuse']) ? filter_var($_POST['is_excuse'], FILTER_VALIDATE_BOOLEAN) : false;

if (empty($post_id) || empty($user_id)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (post_id, user_id).']);
    exit();
}

$urls = [];
$allowedTypes = ['image/jpeg', 'image/png', 'video/mp4', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
$maxSize = 10 * 1024 * 1024; // 10MB

if (!empty($_FILES['files']['name'][0])) {
    foreach ($_FILES['files']['tmp_name'] as $key => $tmp_name) {
        $file_name = $_FILES['files']['name'][$key];
        $file_size = $_FILES['files']['size'][$key];
        $file_type = $_FILES['files']['type'][$key];
        $file_error = $_FILES['files']['error'][$key];

        if ($file_error !== UPLOAD_ERR_OK) {
            continue;
        }

        if ($file_size > $maxSize) {
            http_response_code(400);
            $msg = "File $file_name exceeds 10MB limit.";
            log_error($msg);
            echo json_encode(['status' => 'error', 'message' => $msg]);
            exit();
        }

        if (!in_array($file_type, $allowedTypes)) {
            http_response_code(400);
            $msg = "File type $file_type not allowed for $file_name.";
            log_error($msg);
            echo json_encode(['status' => 'error', 'message' => $msg]);
            exit();
        }

        $fileData = file_get_contents($tmp_name);
        $unique_name = uniqid() . '_' . preg_replace('/[^A-Za-z0-9.\-_]/', '', $file_name);
        
        $uploadUrl = "/storage/v1/object/proofs/" . $unique_name;
        
        // Upload to Supabase Storage
        $uploadResponse = supabase_request($uploadUrl, 'POST', $fileData, [
            'Content-Type: ' . $file_type
        ]);

        if ($uploadResponse['status'] >= 200 && $uploadResponse['status'] < 300) {
            $urls[] = SUPABASE_URL . "/storage/v1/object/public/proofs/" . $unique_name;
        } else {
            http_response_code(500);
            log_error("Supabase Storage Error: " . print_r($uploadResponse, true));
            echo json_encode(['status' => 'error', 'message' => 'Failed to upload to storage', 'details' => $uploadResponse]);
            exit();
        }
    }
} else if (!$is_excuse) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'No files uploaded.']);
    exit();
}

$file_url = json_encode($urls);

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
    log_error("Database Error: " . print_r($response['data'], true));
    echo json_encode(['status' => 'error', 'message' => 'Failed to submit proof record.', 'details' => $response['data']]);
}
?>
