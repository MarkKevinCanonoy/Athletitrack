<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed.']);
    exit();
}

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['team_id']) || empty($inputData['coach_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (team_id, coach_id).']);
    exit();
}

$team_id = $inputData['team_id'];
$coach_id = $inputData['coach_id'];

// Supabase REST DELETE endpoint
$response = supabase_request("/rest/v1/teams?id=eq." . urlencode($team_id) . "&coach_id=eq." . urlencode($coach_id), 'DELETE');

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Team deleted successfully.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete team.', 'details' => $response['data']]);
}
?>
