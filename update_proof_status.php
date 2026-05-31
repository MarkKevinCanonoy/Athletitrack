<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['proof_id']) || empty($inputData['status'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing proof_id or status.']);
    exit();
}

$proof_id = $inputData['proof_id'];
$status = $inputData['status'];
$coach_note = $inputData['coach_note'] ?? null;

if (!in_array($status, ['approved', 'rejected'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid status.']);
    exit();
}

$data = ['status' => $status];
if ($status === 'rejected' && $coach_note !== null) {
    $data['coach_note'] = $coach_note;
}

$response = supabase_request("/rest/v1/proofs?id=eq." . urlencode($proof_id), 'PATCH', $data);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success']);
} else {
    http_response_code(500);
    require_once 'debug_helper.php';
    log_error("Update proof status error: " . print_r($response, true));
    echo json_encode(['status' => 'error', 'message' => 'Failed to update status', 'details' => $response['data']]);
}
?>
