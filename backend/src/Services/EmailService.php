<?php

namespace App\Services;

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class EmailService {
    
    /**
     * Sends an OTP via Gmail SMTP
     * @param string $recipientEmail
     * @param string $otp
     * @return bool
     */
    public function sendOtp(string $recipientEmail, string $otp): bool {
        $mail = new PHPMailer(true);

        try {
            // Server settings
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com'; 
            $mail->SMTPAuth   = true;
            // In production, load from env variables
            $mail->Username   = getenv('SMTP_USER') ?: 'test@gmail.com';
            $mail->Password   = getenv('SMTP_PASS') ?: 'password';
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port       = 587;

            // Recipients
            $mail->setFrom('noreply@athletitrack.com', 'AthletiTrack Admin');
            $mail->addAddress($recipientEmail);

            // Content
            $mail->isHTML(true);
            $mail->Subject = 'Your AthletiTrack OTP Code';
            $mail->Body    = "Your verification code is: <b>{$otp}</b>. This code will expire in 5 minutes.";
            $mail->AltBody = "Your verification code is: {$otp}. This code will expire in 5 minutes.";

            $mail->send();
            return true;
        } catch (Exception $e) {
            error_log("Message could not be sent. Mailer Error: {$mail->ErrorInfo}");
            return false;
        }
    }
}
