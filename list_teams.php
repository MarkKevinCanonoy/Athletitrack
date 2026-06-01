<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (!empty($inputData['coach_id'])) {
    $coach_id = $inputData['coach_id'];
    $response = supabase_request("/rest/v1/teams?select=*,team_members(count),posts(id,title,session_date,session_time,is_weekly,days_of_week)&coach_id=eq." . urlencode($coach_id) . "&team_members.status=eq.approved&posts.type=eq.training", 'GET');
    
    if ($response['status'] === 200) {
        $teams = array_map(function($team) {
            $team['athlete_count'] = isset($team['team_members'][0]['count']) ? $team['team_members'][0]['count'] : 0;
            return $team;
        }, $response['data']);
        echo json_encode(['status' => 'success', 'teams' => $teams]);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to fetch teams.', 'details' => $response['data']]);
    }
} else if (!empty($inputData['athlete_id'])) {
    $athlete_id = $inputData['athlete_id'];
    $response = supabase_request("/rest/v1/team_members?athlete_id=eq." . urlencode($athlete_id) . "&status=eq.approved&select=teams(*,team_members(count),posts(id,title,session_date,session_time,is_weekly,days_of_week))", 'GET');
    
    if ($response['status'] === 200) {
        $teams = array_map(function($t) { 
            $team = $t['teams'];
            $team['athlete_count'] = isset($team['team_members'][0]['count']) ? $team['team_members'][0]['count'] : 0;
            return $team;
        }, $response['data'] ?? []);
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
