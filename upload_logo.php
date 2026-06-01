<?php
// C:\xampp\htdocs\athletitrack-api\upload_logo.php
require_once 'config.php';
require_once 'debug_helper.php';
header("Content-Type: application/json; charset=UTF-8");

$allowedTypes = ['image/jpeg', 'image/png'];
$maxSize = 5 * 1024 * 1024; // 5MB

if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
    $file_name = $_FILES['logo']['name'];
    $file_size = $_FILES['logo']['size'];
    $file_type = $_FILES['logo']['type'];
    $tmp_name = $_FILES['logo']['tmp_name'];

    if ($file_size > $maxSize) {
        http_response_code(400);
        $msg = "File exceeds 5MB limit.";
        log_error($msg);
        echo json_encode(['status' => 'error', 'message' => $msg]);
        exit();
    }

    if (!in_array($file_type, $allowedTypes)) {
        http_response_code(400);
        $msg = "Only JPG and PNG images are allowed.";
        log_error($msg);
        echo json_encode(['status' => 'error', 'message' => $msg]);
        exit();
    }

    $fileData = file_get_contents($tmp_name);
    $unique_name = uniqid() . '_' . preg_replace('/[^A-Za-z0-9.\-_]/', '', $file_name);
    
    // We can use the 'proofs' bucket if 'logos' doesn't exist, or create 'logos' bucket. 
    // It's safer to use the existing 'proofs' bucket just in case 'logos' isn't public or doesn't exist.
    // Or we could try 'logos'. I'll stick to 'proofs' for now, but place it in a logos folder.
    $uploadUrl = "/storage/v1/object/proofs/logos/" . $unique_name;
    
    $uploadResponse = supabase_request($uploadUrl, 'POST', $fileData, [
        'Content-Type: ' . $file_type
    ]);

    if ($uploadResponse['status'] >= 200 && $uploadResponse['status'] < 300) {
        $publicUrl = SUPABASE_URL . "/storage/v1/object/public/proofs/logos/" . $unique_name;
        echo json_encode(['status' => 'success', 'logo_url' => $publicUrl]);
    } else {
        http_response_code(500);
        log_error("Supabase Storage Error: " . print_r($uploadResponse, true));
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload logo to storage', 'details' => $uploadResponse]);
    }
} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'No logo file provided or upload error.']);
}
?>
