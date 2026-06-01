<?php
require 'config.php';
$response = supabase_request('/rest/v1/otp_requests?email=eq.test_athletitrack@evsu.edu.ph&select=*', 'GET');
print_r($response);
?>
