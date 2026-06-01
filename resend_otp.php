<?php
// C:\xampp\htdocs\athletitrack-api\resend_otp.php
require_once 'config.php';
require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

header('Content-Type: application/json');
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing email']);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);

// 1. Find the existing OTP request
$response = supabase_request("/rest/v1/otp_requests?email=ilike." . urlencode($email) . "&select=*");

if ($response['status'] != 200 || empty($response['data'])) {
    echo json_encode(['status' => 'error', 'message' => 'No pending registration found for this email.']);
    exit();
}

$requestData = $response['data'][0];
$fullName = $requestData['full_name'];

// 2. Generate a NEW 6-digit OTP and new expiration
$new_otp = sprintf("%06d", mt_rand(1, 999999));
$expires_at = gmdate('Y-m-d\TH:i:s\Z', strtotime('+5 minutes'));

// 3. Update the OTP request in the database
$updateData = [
    'otp_code' => $new_otp,
    'expires_at' => $expires_at
];

$updateResponse = supabase_request("/rest/v1/otp_requests?id=eq." . $requestData['id'], 'PATCH', $updateData);

if ($updateResponse['status'] >= 400) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update OTP request.', 'details' => $updateResponse['data']]);
    exit();
}

// 4. Send Email via PHPMailer
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
    $mail->addAddress($email, $fullName);

    $mail->isHTML(true);
    $mail->Subject = 'Your NEW AthletiTrack Verification Code';
    $mail->Body    = "Hello $fullName,<br><br>You requested a new verification code. Your new code is: <b>$new_otp</b><br><br>This code expires in 5 minutes.";
    $mail->AltBody = "Hello $fullName,\n\nYou requested a new verification code. Your new code is: $new_otp\n\nThis code expires in 5 minutes.";

    $mail->send();
    echo json_encode(['status' => 'success', 'message' => 'New OTP sent to your email.']);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => "Message could not be sent. Mailer Error: {$mail->ErrorInfo}"]);
}
?>
