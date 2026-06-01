<?php
require_once 'config.php';

header('Content-Type: application/json');
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['otp']) || !isset($data['new_password'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
$otp = $data['otp'];
$new_password = $data['new_password'];

if (strlen($new_password) < 8) {
    echo json_encode(['status' => 'error', 'message' => 'Password must be at least 8 characters long.']);
    exit();
}

// 1. Find OTP request
$checkOtp = supabase_request("/rest/v1/password_resets?email=eq." . urlencode($email) . "&order=created_at.desc&limit=1");
if ($checkOtp['status'] != 200 || empty($checkOtp['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'No pending reset request found or it has expired.']);
    exit();
}

$resetRecord = $checkOtp['data'][0];
$recordId = $resetRecord['id'];

// Check expiry
$expiresAt = strtotime($resetRecord['expires_at']);
if (time() > $expiresAt) {
    supabase_request("/rest/v1/password_resets?id=eq." . urlencode($recordId), 'DELETE');
    echo json_encode(['status' => 'error', 'message' => 'OTP has expired. Please request a new one.']);
    exit();
}

// Verify OTP
if (!password_verify($otp, $resetRecord['otp_hash'])) {
    $failedAttempts = $resetRecord['failed_attempts'] + 1;
    if ($failedAttempts >= 3) {
        supabase_request("/rest/v1/password_resets?id=eq." . urlencode($recordId), 'DELETE');
        echo json_encode(['status' => 'error', 'message' => 'Too many failed attempts. Reset request cancelled.']);
    } else {
        supabase_request("/rest/v1/password_resets?id=eq." . urlencode($recordId), 'PATCH', ['failed_attempts' => $failedAttempts]);
        echo json_encode(['status' => 'error', 'message' => 'Invalid OTP. Please check and try again.']);
    }
    exit();
}

// 2. Update User password
$password_hash = password_hash($new_password, PASSWORD_BCRYPT);
$updateRes = supabase_request("/rest/v1/users?email=eq." . urlencode($email), 'PATCH', ['password_hash' => $password_hash]);

if ($updateRes['status'] >= 400) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update password.']);
    exit();
}

// 3. Delete OTP record (single-use)
supabase_request("/rest/v1/password_resets?id=eq." . urlencode($recordId), 'DELETE');

echo json_encode(['status' => 'success', 'message' => 'Password reset successfully. You can now log in.']);
?>
