<?php
require 'config.php';
$post_id = '7ab6fb69-b1a3-4e26-b6f9-48affc3c5486';
$user_id = '02185c20-d76e-4d90-8e8c-d2b555f9d96e';

$insertData = [
    'post_id' => $post_id,
    'athlete_id' => $user_id,
    'file_url' => '[]',
    'status' => 'pending',
    'is_excuse' => false,
    'comment' => 'test'
];
$response = supabase_request("/rest/v1/proofs", 'POST', $insertData);
print_r($response);
?>
