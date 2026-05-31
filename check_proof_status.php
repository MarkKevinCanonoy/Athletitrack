<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");
$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['user_id']) || empty($inputData['post_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing fields.']);
    exit();
}

$user_id = $inputData['user_id'];
$post_id = $inputData['post_id'];

$res = supabase_request("/rest/v1/proofs?athlete_id=eq." . urlencode($user_id) . "&post_id=eq." . urlencode($post_id) . "&order=submitted_at.desc", 'GET');
if ($res['status'] == 200 && !empty($res['data'])) {
    echo json_encode(['status' => 'success', 'proof' => $res['data'][0]]);
} else {
    echo json_encode(['status' => 'success', 'proof' => null]);
}
?>
