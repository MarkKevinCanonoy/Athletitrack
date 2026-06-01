<?php
require_once 'config.php';
require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

header('Content-Type: application/json');
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);

// 1. Anti-enumeration: Check if user exists. If they don't, we still return success but don't send an email.
$checkUser = supabase_request("/rest/v1/users?email=eq." . urlencode($email));
if ($checkUser['status'] != 200 || empty($checkUser['data'])) {
    // Return success to prevent enumeration, but wait a bit to avoid timing attacks
    usleep(random_int(300000, 500000));
    echo json_encode(['status' => 'success', 'message' => 'If an account exists, an OTP has been sent.']);
    exit();
}
$user = $checkUser['data'][0];

// 2. Rate limiting / Cooldown
$checkResets = supabase_request("/rest/v1/password_resets?email=eq." . urlencode($email) . "&order=created_at.desc&limit=3");
if ($checkResets['status'] == 200 && !empty($checkResets['data'])) {
    $recentRequests = $checkResets['data'];
    if (count($recentRequests) >= 3) {
        $oldest = strtotime($recentRequests[2]['created_at']);
        $now = time();
        if ($now - $oldest < 900) { // 3 requests in 15 mins max
            echo json_encode(['status' => 'error', 'message' => 'Too many requests. Please try again later.']);
            exit();
        }
    }
}

// 3. Generate secure 6-digit OTP
$otp = sprintf("%06d", random_int(0, 999999));
$expires_at = gmdate('Y-m-d\TH:i:s\Z', strtotime('+10 minutes'));
$otp_hash = password_hash($otp, PASSWORD_BCRYPT);

// 4. Save to password_resets
supabase_request("/rest/v1/password_resets?email=eq." . urlencode($email), 'DELETE'); // clear old

$otpData = [
    'email' => $email,
    'otp_hash' => $otp_hash,
    'expires_at' => $expires_at
];

$insertResponse = supabase_request("/rest/v1/password_resets", 'POST', $otpData);

if ($insertResponse['status'] >= 400) {
    echo json_encode([
        'status' => 'error', 
        'message' => 'Failed to save reset request. Did you create the password_resets table in Supabase?',
        'details' => $insertResponse['data']
    ]);
    exit();
}

// 5. Send Email
$mail = new PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = SMTP_EMAIL;
    $mail->Password   = SMTP_APP_PASSWORD;
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port       = 587;

    $mail->setFrom(SMTP_EMAIL, 'AthletiTrack Admin');
    $mail->addAddress($email, $user['full_name']);

    $mail->isHTML(true);
    $mail->Subject = 'Password Reset Request';
    $mail->Body    = "Hello {$user['full_name']},<br><br>Your password reset code is: <b style='font-size:24px'>$otp</b><br><br>This code expires in 10 minutes. If you did not request this, please ignore this email.";
    $mail->AltBody = "Hello {$user['full_name']},\n\nYour password reset code is: $otp\n\nThis code expires in 10 minutes.";

    $mail->send();
    echo json_encode(['status' => 'success', 'message' => 'If an account exists, an OTP has been sent.']);
} catch (Exception $e) {
    supabase_request("/rest/v1/password_resets?email=eq." . urlencode($email), 'DELETE');
    echo json_encode(['status' => 'error', 'message' => "Message could not be sent. Mailer Error: {$mail->ErrorInfo}"]);
}
?>
