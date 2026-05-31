<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['proof_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing proof_id.']);
    exit();
}

$proof_id = $inputData['proof_id'];
$response = supabase_request("/rest/v1/proofs?id=eq." . urlencode($proof_id), 'DELETE');

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Proof unsubmitted successfully.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to unsubmit proof.']);
}
?>
