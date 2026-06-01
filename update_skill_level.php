<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");
$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['team_id']) || empty($inputData['athlete_id']) || empty($inputData['skill_level'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields.']);
    exit();
}

$team_id = $inputData['team_id'];
$athlete_id = $inputData['athlete_id'];
$skill_level = $inputData['skill_level']; // 'Beginner', 'Intermediate', or 'Expert'

// Update the team member's skill level
$payload = json_encode(['skill_level' => $skill_level]);
$res = supabase_request("/rest/v1/team_members?team_id=eq." . urlencode($team_id) . "&athlete_id=eq." . urlencode($athlete_id), 'PATCH', $payload);

if ($res['status'] == 200 || $res['status'] == 204) {
    echo json_encode(['status' => 'success']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to update skill level.']);
}
?>
