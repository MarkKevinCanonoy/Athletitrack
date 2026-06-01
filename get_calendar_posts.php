<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");
$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['user_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing user_id.']);
    exit();
}
$user_id = $inputData['user_id'];

// Get all teams for the coach
$teamsRes = supabase_request("/rest/v1/teams?coach_id=eq." . urlencode($user_id), 'GET');
$teams = $teamsRes['status'] == 200 ? $teamsRes['data'] : [];

if (empty($teams)) {
    echo json_encode(['status' => 'success', 'posts' => []]);
    exit();
}

$teamIds = array_column($teams, 'id');
$teamIdStr = implode(',', $teamIds);

// Fetch posts for these teams
$postsRes = supabase_request("/rest/v1/posts?team_id=in.(" . urlencode($teamIdStr) . ")&type=eq.training&select=*,teams(name)", 'GET');
if ($postsRes['status'] == 200) {
    echo json_encode(['status' => 'success', 'posts' => $postsRes['data']]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Failed to fetch posts.']);
}
?>
