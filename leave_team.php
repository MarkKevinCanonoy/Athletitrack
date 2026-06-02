<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed.']);
    exit();
}

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['team_id']) || empty($inputData['athlete_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (team_id, athlete_id).']);
    exit();
}

$team_id = $inputData['team_id'];
$athlete_id = $inputData['athlete_id'];

// Supabase REST DELETE endpoint for team_members
$response = supabase_request("/rest/v1/team_members?team_id=eq." . urlencode($team_id) . "&athlete_id=eq." . urlencode($athlete_id), 'DELETE');

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Successfully left the team.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to leave team.', 'details' => $response['data']]);
}
?>
