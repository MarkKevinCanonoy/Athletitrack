<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['athlete_id']) || empty($inputData['team_code'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (athlete_id, team_code).']);
    exit();
}

$athlete_id = $inputData['athlete_id'];
$team_code = $inputData['team_code'];

// 1. Find team by code
$teamRes = supabase_request("/rest/v1/teams?code=eq." . urlencode($team_code), 'GET');
if ($teamRes['status'] !== 200 || empty($teamRes['data'])) {
    http_response_code(404);
    echo json_encode(['status' => 'error', 'message' => 'Invalid team code.']);
    exit();
}
$team_id = $teamRes['data'][0]['id'];

// 2. Insert into team_members
$insertData = [
    'team_id' => $team_id,
    'athlete_id' => $athlete_id,
    'status' => 'pending'
];

$response = supabase_request("/rest/v1/team_members", 'POST', $insertData);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Join request sent. Waiting for coach approval.']);
} else {
    // If unique constraint violated (already joined or pending)
    if (isset($response['data']['code']) && $response['data']['code'] === '23505') {
         http_response_code(409);
         echo json_encode(['status' => 'error', 'message' => 'You have already joined or requested to join this team.']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to join team.', 'details' => $response['data']]);
    }
}
?>
