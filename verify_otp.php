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
$response = supabase_request("/rest/v1/otp_requests?email=ilike." . urlencode($email) . "&select=*");

if ($response['status'] != 200 || empty($response['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'No pending registration found for this email.']);
    exit();
}

$requestData = $response['data'][0];

// 2. Check if in cooldown
if (!empty($requestData['cooldown_until'])) {
    $cooldown_until = strtotime($requestData['cooldown_until']);
    $now = time();
    if ($now < $cooldown_until) {
        $minutes_left = ceil(($cooldown_until - $now) / 60);
        echo json_encode(['status' => 'error', 'message' => "Too many failed attempts. Please try again in {$minutes_left} minutes."]);
        exit();
    }
}

// 3. Check if expired
$expires_at = strtotime($requestData['expires_at']);
$now = time();

if ($now > $expires_at) {
    // Clean up expired request
    supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'DELETE');
    echo json_encode(['status' => 'error', 'message' => 'OTP has expired. Please register again.']);
    exit();
}

// 4. Verify the code
if ($requestData['otp_code'] !== $otp_code) {
    $failed_attempts = (int)($requestData['failed_attempts'] ?? 0) + 1;
    $updateData = ['failed_attempts' => $failed_attempts];
    
    if ($failed_attempts >= 3) {
        $updateData['cooldown_until'] = gmdate('Y-m-d\TH:i:s\Z', time() + 600); // 10 minutes from now
        supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'PATCH', $updateData);
        echo json_encode(['status' => 'error', 'message' => 'Too many failed attempts. Please try again in 10 minutes.']);
        exit();
    } else {
        supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'PATCH', $updateData);
        $attempts_left = 3 - $failed_attempts;
        echo json_encode(['status' => 'error', 'message' => "Invalid OTP code. $attempts_left attempts remaining."]);
        exit();
    }
}

// 5. Move data to 'users' table
$userData = [
    'full_name' => $requestData['full_name'],
    'email' => $requestData['email'],
    'password_hash' => $requestData['password_hash'],
    'role' => $requestData['role']
];

$insertResponse = supabase_request("/rest/v1/users", 'POST', $userData);

if ($insertResponse['status'] >= 400 || empty($insertResponse['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to create user account.', 'details' => $insertResponse['data'] ?? 'Unknown error']);
    exit();
}

$newUser = $insertResponse['data'][0];

// 6. Generate a simple JWT token
$header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
$payload = json_encode([
    'user_id' => $newUser['id'],
    'role' => $newUser['role'],
    'exp' => time() + (86400 * 7) // 7 days expiration
]);

$base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
$base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

$signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, SUPABASE_KEY, true);
$base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

$jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;

// 7. Clean up OTP request
supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'DELETE');

echo json_encode([
    'status' => 'success', 
    'message' => 'Account successfully verified and created.',
    'token' => $jwt,
    'user' => [
        'id' => $newUser['id'],
        'full_name' => $newUser['full_name'],
        'email' => $newUser['email'],
        'role' => $newUser['role']
    ]
]);
?>
