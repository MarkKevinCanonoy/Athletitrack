<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['coach_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing coach_id.']);
    exit();
}

$coach_id = $inputData['coach_id'];

// We need to fetch team_members where status=pending AND the team belongs to this coach.
// We can use Supabase's embedded resource routing if we had foreign keys set up correctly,
// but since we only have direct REST API access from here, we will fetch the coach's teams first.

$teamsRes = supabase_request("/rest/v1/teams?coach_id=eq." . urlencode($coach_id), 'GET');
if ($teamsRes['status'] !== 200) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to fetch coach teams.']);
    exit();
}

$teams = $teamsRes['data'];
if (empty($teams)) {
    echo json_encode(['status' => 'success', 'requests' => []]);
    exit();
}

$teamIds = array_column($teams, 'id');
$teamIdsStr = implode(',', $teamIds);

// Now fetch pending team_members for these team IDs, expanding the athlete (users) and teams
// Assuming Supabase foreign keys are properly set for embedding: 
$query = "/rest/v1/team_members?status=eq.pending&team_id=in.(" . $teamIdsStr . ")&select=id,status,joined_at,team_id,teams(name),users!athlete_id(full_name,email)";

$reqRes = supabase_request($query, 'GET');

if ($reqRes['status'] == 200) {
    echo json_encode(['status' => 'success', 'requests' => $reqRes['data']]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to fetch requests.', 'details' => $reqRes['data']]);
}
?>
