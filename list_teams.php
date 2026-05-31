<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (!empty($inputData['coach_id'])) {
    $coach_id = $inputData['coach_id'];
    $response = supabase_request("/rest/v1/teams?coach_id=eq." . urlencode($coach_id), 'GET');
    
    if ($response['status'] === 200) {
        echo json_encode(['status' => 'success', 'teams' => $response['data']]);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to fetch teams.', 'details' => $response['data']]);
    }
} else if (!empty($inputData['athlete_id'])) {
    $athlete_id = $inputData['athlete_id'];
    $response = supabase_request("/rest/v1/team_members?athlete_id=eq." . urlencode($athlete_id) . "&status=eq.approved&select=teams(*)", 'GET');
    
    if ($response['status'] === 200) {
        $teams = array_map(function($t) { return $t['teams']; }, $response['data'] ?? []);
        echo json_encode(['status' => 'success', 'teams' => $teams]);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to fetch teams.', 'details' => $response['data']]);
    }
} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing coach_id or athlete_id.']);
}
?>
