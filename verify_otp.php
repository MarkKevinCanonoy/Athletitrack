<?php
// C:\xampp\htdocs\athletitrack-api\verify_otp.php
require_once 'config.php';

header('Content-Type: application/json');
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['otp_code'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing email or OTP code']);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
$otp_code = $data['otp_code'];

// 1. Find the OTP request in the database
$response = supabase_request("/rest/v1/otp_requests?email=eq." . urlencode($email) . "&select=*");

if ($response['status'] != 200 || empty($response['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'No pending registration found for this email.']);
    exit();
}

$requestData = $response['data'][0];

// 2. Check if expired
$expires_at = strtotime($requestData['expires_at']);
$now = time();

if ($now > $expires_at) {
    // Clean up expired request
    supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'DELETE');
    echo json_encode(['status' => 'error', 'message' => 'OTP has expired. Please register again.']);
    exit();
}

// 3. Verify the code
if ($requestData['otp_code'] !== $otp_code) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid OTP code.']);
    exit();
}

// 4. Move data to 'users' table
$userData = [
    'full_name' => $requestData['full_name'],
    'email' => $requestData['email'],
    'password_hash' => $requestData['password_hash'],
    'role' => $requestData['role']
];

$insertResponse = supabase_request("/rest/v1/users", 'POST', $userData);

if ($insertResponse['status'] >= 400) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to create user account.', 'details' => $insertResponse['data']]);
    exit();
}

// 5. Clean up OTP request
supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'DELETE');

echo json_encode(['status' => 'success', 'message' => 'Account successfully verified and created. You can now log in.']);
?>
