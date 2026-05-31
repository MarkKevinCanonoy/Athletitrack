<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['request_id']) || empty($inputData['action'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing request_id or action (approve/reject).']);
    exit();
}

$request_id = $inputData['request_id'];
$action = $inputData['action'];

if ($action === 'approve') {
    $response = supabase_request("/rest/v1/team_members?id=eq." . urlencode($request_id), 'PATCH', ['status' => 'approved']);
    if ($response['status'] >= 200 && $response['status'] < 300) {
        echo json_encode(['status' => 'success', 'message' => 'Athlete approved.']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to approve.', 'details' => $response['data']]);
    }
} else if ($action === 'reject') {
    $response = supabase_request("/rest/v1/team_members?id=eq." . urlencode($request_id), 'DELETE');
    if ($response['status'] >= 200 && $response['status'] < 300) {
        echo json_encode(['status' => 'success', 'message' => 'Request rejected and removed.']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to reject.', 'details' => $response['data']]);
    }
} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid action.']);
}
?>
