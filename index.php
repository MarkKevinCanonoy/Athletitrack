<?php
// C:\xampp\htdocs\athletitrack-api\index.php
require_once 'config.php';

// A simple test route to verify the connection is working
header('Content-Type: application/json');

$response = supabase_request('/rest/v1/users?select=id');

if ($response['status'] == 200) {
    echo json_encode([
        'status' => 'success',
        'message' => 'Successfully connected to Supabase! Your backend is alive.',
        'data' => $response['data']
    ]);
} else if ($response['status'] == 0) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to connect. Check if your SUPABASE_URL in config.php is correct and does not have a trailing slash.'
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Connected to Supabase, but received an error. Check your API Key.',
        'details' => $response['data']
    ]);
}
?>
