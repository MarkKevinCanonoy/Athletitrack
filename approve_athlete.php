<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

if (empty($inputData['request_id']) || empty($inputData['action'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing request_id or action (approve/reject).']);
    exit();
}

$request_id = $inputData['request_id'];
$action = $inputData['action'];

// Fetch request info first to get athlete_id and team_name for the notification
$reqRes = supabase_request("/rest/v1/team_members?id=eq." . urlencode($request_id) . "&select=athlete_id,teams(name)", 'GET');
if ($reqRes['status'] != 200 || empty($reqRes['data'])) {
    http_response_code(404);
    echo json_encode(['status' => 'error', 'message' => 'Request not found.']);
    exit();
}
$athlete_id = $reqRes['data'][0]['athlete_id'];
$team_name = $reqRes['data'][0]['teams']['name'];

if ($action === 'approve') {
    $response = supabase_request("/rest/v1/team_members?id=eq." . urlencode($request_id), 'PATCH', ['status' => 'approved']);
    if ($response['status'] >= 200 && $response['status'] < 300) {
        $notifData = [
            'user_id' => $athlete_id,
            'type' => 'approval',
            'message' => "Your request to join $team_name has been approved!"
        ];
        supabase_request("/rest/v1/notifications", 'POST', $notifData);
        echo json_encode(['status' => 'success', 'message' => 'Athlete approved.']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to approve.', 'details' => $response['data']]);
    }
} else if ($action === 'reject') {
    $response = supabase_request("/rest/v1/team_members?id=eq." . urlencode($request_id), 'DELETE');
    if ($response['status'] >= 200 && $response['status'] < 300) {
        $notifData = [
            'user_id' => $athlete_id,
            'type' => 'rejection',
            'message' => "Your request to join $team_name was rejected."
        ];
        supabase_request("/rest/v1/notifications", 'POST', $notifData);
        echo json_encode(['status' => 'success', 'message' => 'Request rejected and removed.']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to reject.', 'details' => $response['data']]);
    }
} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid action.']);
}
?>
