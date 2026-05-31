<?php
require 'config.php';

$bucketData = [
    'id' => 'proofs',
    'name' => 'proofs',
    'public' => true
];

$response = supabase_request('/storage/v1/bucket', 'POST', $bucketData);
print_r($response);
?>
