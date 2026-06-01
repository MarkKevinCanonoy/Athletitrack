<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['coach_id']) || empty($inputData['name']) || empty($inputData['team_code'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields (coach_id, name, team_code).']);
    exit();
}

$coach_id = $inputData['coach_id'];
$name = $inputData['name'];
$category = $inputData['category'] ?? null;
$skill_level = $inputData['skill_level'] ?? null;
$team_code = $inputData['team_code'];
$logo_url = $inputData['logo_url'] ?? null;

// Check if team code already exists
$existing = supabase_request("/rest/v1/teams?code=eq." . urlencode($team_code), 'GET');
if ($existing['status'] === 200 && !empty($existing['data'])) {
    http_response_code(409);
    echo json_encode(['status' => 'error', 'message' => 'Team code already exists. Try generating another one.']);
    exit();
}

$insertData = [
    'coach_id' => $coach_id,
    'name' => $name,
    'code' => $team_code,
    'description' => $inputData['description'] ?? null,
    'category' => $category,
    'skill_level' => $skill_level,
    'logo_url' => $logo_url
];

$response = supabase_request("/rest/v1/teams", 'POST', $insertData);

if ($response['status'] >= 200 && $response['status'] < 300) {
    echo json_encode(['status' => 'success', 'message' => 'Team created successfully.', 'team' => $response['data'][0] ?? $response['data']]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to create team.', 'details' => $response['data']]);
}
?>
