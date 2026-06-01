<?php
// C:\xampp\htdocs\athletitrack-api\register.php
require_once 'config.php';
require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

header('Content-Type: application/json');
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['full_name']) || !isset($data['email']) || !isset($data['password']) || !isset($data['role'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
$password = $data['password'];
$fullName = $data['full_name'];
$role = $data['role'];

// 1. Check if email already exists in 'users' table
$checkUser = supabase_request("/rest/v1/users?email=eq." . urlencode($email));
if ($checkUser['status'] == 200 && !empty($checkUser['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'Email already registered.']);
    exit();
}

// 2. Generate a 6-digit OTP
$otp = sprintf("%06d", mt_rand(1, 999999));
$expires_at = gmdate('Y-m-d\TH:i:s\Z', strtotime('+5 minutes'));
$password_hash = password_hash($password, PASSWORD_BCRYPT);

// 3. Save to 'otp_requests' table in Supabase
// First, delete any existing pending OTPs for this email to avoid duplicates
supabase_request("/rest/v1/otp_requests?email=eq." . urlencode($email), 'DELETE');

$otpData = [
    'email' => $email,
    'full_name' => $fullName,
    'password_hash' => $password_hash,
    'role' => $role,
    'otp_code' => $otp,
    'expires_at' => $expires_at
];

$insertResponse = supabase_request("/rest/v1/otp_requests", 'POST', $otpData);

if ($insertResponse['status'] >= 400) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to save OTP request to database.', 'details' => $insertResponse['data']]);
    exit();
}

// 4. Send Email via PHPMailer
$mail = new PHPMailer(true);
try {
    // Server settings
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = SMTP_EMAIL;
    $mail->Password   = SMTP_APP_PASSWORD;
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port       = 587;

    // Recipients
    $mail->setFrom(SMTP_EMAIL, 'AthletiTrack Admin');
    $mail->addAddress($email, $fullName);

    // Content
    $mail->isHTML(true);
    $mail->Subject = 'Your AthletiTrack Verification Code';
    $mail->Body    = "Hello $fullName,<br><br>Your verification code is: <b>$otp</b><br><br>This code expires in 5 minutes.";
    $mail->AltBody = "Hello $fullName,\n\nYour verification code is: $otp\n\nThis code expires in 5 minutes.";

    $mail->send();
    echo json_encode(['status' => 'success', 'message' => 'OTP sent to email.']);
} catch (Exception $e) {
    // Cleanup the database request if email fails
    supabase_request("/rest/v1/otp_requests?email=eq." . urlencode($email), 'DELETE');
    echo json_encode(['status' => 'error', 'message' => "Message could not be sent. Mailer Error: {$mail->ErrorInfo}"]);
}
?>
