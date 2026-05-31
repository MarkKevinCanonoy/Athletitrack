<?php
// C:\xampp\htdocs\athletitrack-api\login.php
require_once 'config.php';

header('Content-Type: application/json');
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['password'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing email or password']);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
$password = $data['password'];

// 1. Fetch user by email
$response = supabase_request("/rest/v1/users?email=eq." . urlencode($email) . "&select=*");

if ($response['status'] != 200 || empty($response['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email or password.']);
    exit();
}

$userData = $response['data'][0];

// 2. Verify password
if (!password_verify($password, $userData['password_hash'])) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email or password.']);
    exit();
}

// 3. Generate a simple JWT token (For a school project, a basic signed token is sufficient)
// In a production app, use a robust JWT library like firebase/php-jwt
$header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
$payload = json_encode([
    'user_id' => $userData['id'],
    'role' => $userData['role'],
    'exp' => time() + (86400 * 7) // 7 days expiration
]);

$base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
$base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

$signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, SUPABASE_KEY, true);
$base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

$jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;

// 4. Return success with token and user info
echo json_encode([
    'status' => 'success',
    'message' => 'Login successful',
    'token' => $jwt,
    'user' => [
        'id' => $userData['id'],
        'full_name' => $userData['full_name'],
        'email' => $userData['email'],
        'role' => $userData['role']
    ]
]);
?>
