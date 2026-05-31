<?php

namespace App\Api;

use App\Services\DatabaseService;
use App\Services\EmailService;

class AuthController {
    private DatabaseService $db;
    private EmailService $emailService;

    public function __construct() {
        $this->db = new DatabaseService();
        $this->emailService = new EmailService();
    }

    public function register(array $data) {
        // Validate payload
        if (empty($data['email']) || empty($data['name']) || empty($data['role'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields.']);
            return;
        }

        // Generate 6-digit OTP
        $otp = sprintf("%06d", mt_rand(1, 999999));
        
        // Temporarily store OTP (In a real scenario, use Redis or a DB table)
        // file_put_contents('/tmp/otp_' . md5($data['email']), $otp);

        // Send OTP
        $sent = $this->emailService->sendOtp($data['email'], $otp);

        if ($sent) {
            echo json_encode(['status' => 'success', 'message' => 'OTP sent to email.', 'mock_otp' => $otp]); // Exposing for dev/testing only
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to send OTP.']);
        }
    }

    public function verifyOtp(array $data) {
        if (empty($data['email']) || empty($data['otp'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing email or OTP.']);
            return;
        }

        // Logic to verify OTP (mocked for now assuming validation passed)
        $isValid = true; // $data['otp'] === stored_otp
        
        if ($isValid) {
            // Check if user exists
            $user = $this->db->select('users', ['email=eq.' . $data['email']]);
            
            if (empty($user)) {
                // Register new user
                $user = $this->db->insert('users', [
                    'email' => $data['email'],
                    'name' => $data['name'] ?? 'Unknown',
                    'role' => $data['role'] ?? 'Athlete'
                ]);
            }

            // Return JWT token (mocked)
            $token = base64_encode(json_encode(['user_id' => $user[0]['id'], 'role' => $user[0]['role']]));

            echo json_encode(['status' => 'success', 'token' => $token, 'user' => $user[0]]);
        } else {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid OTP.']);
        }
    }
}
