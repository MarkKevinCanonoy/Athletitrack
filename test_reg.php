<?php
require 'config.php';
$response = supabase_request('/rest/v1/otp_requests?email=eq.test_athletitrack@evsu.edu.ph', 'DELETE');
print_r($response);

$response2 = supabase_request('/rest/v1/otp_requests', 'POST', [
    'email' => 'test_athletitrack@evsu.edu.ph',
    'full_name' => 'Test',
    'password_hash' => 'hash',
    'role' => 'Athlete',
    'otp_code' => '123456',
    'expires_at' => gmdate('Y-m-d\TH:i:s\Z', strtotime('+5 minutes'))
]);
print_r($response2);
?>
