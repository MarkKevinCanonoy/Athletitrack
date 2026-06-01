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
$notifications = [];

// 1. Get Join Requests for Coach
$teamsRes = supabase_request("/rest/v1/teams?coach_id=eq." . urlencode($user_id) . "&select=id,name", 'GET');
if ($teamsRes['status'] == 200 && !empty($teamsRes['data'])) {
    $teamIds = array_column($teamsRes['data'], 'id');
    $teamIdStr = implode(',', $teamIds);
    $reqsRes = supabase_request("/rest/v1/team_members?team_id=in.($teamIdStr)&status=eq.pending&select=id,athlete_id,team_id,teams(name),users(full_name),joined_at&order=joined_at.desc", 'GET');
    
    if ($reqsRes['status'] == 200 && is_array($reqsRes['data'])) {
        foreach ($reqsRes['data'] as $req) {
            $notifications[] = [
                'type' => 'join_request',
                'id' => $req['id'],
                'athlete_name' => $req['users']['full_name'],
                'team_name' => $req['teams']['name'],
                'message' => $req['users']['full_name'] . ' wants to join ' . $req['teams']['name'],
                'timestamp' => $req['joined_at']
            ];
        }
    }
}

// 2. Get Recent Announcements for Athlete (last 7 days)
$athleteTeamsRes = supabase_request("/rest/v1/team_members?athlete_id=eq." . urlencode($user_id) . "&status=eq.approved&select=team_id,teams(name)", 'GET');
if ($athleteTeamsRes['status'] == 200 && !empty($athleteTeamsRes['data'])) {
    $athTeamIds = array_column($athleteTeamsRes['data'], 'team_id');
    $athTeamIdStr = implode(',', $athTeamIds);
    // last 7 days
    $sevenDaysAgo = date('Y-m-d\TH:i:s.000\Z', strtotime('-7 days'));
    
    $postsRes = supabase_request("/rest/v1/posts?team_id=in.($athTeamIdStr)&type=eq.announcement&created_at=gte.$sevenDaysAgo&select=id,title,team_id,teams(name)&order=created_at.desc", 'GET');
    if ($postsRes['status'] == 200 && is_array($postsRes['data'])) {
        foreach ($postsRes['data'] as $post) {
            $notifications[] = [
                'type' => 'announcement',
                'id' => $post['id'],
                'team_name' => $post['teams']['name'],
                'title' => $post['title'],
                'message' => 'New announcement in ' . $post['teams']['name'] . ': ' . $post['title']
            ];
        }
    }
}

// 3. Get User Specific Notifications (Approvals, Rejections, etc)
$userNotifsRes = supabase_request("/rest/v1/notifications?user_id=eq." . urlencode($user_id) . "&order=created_at.desc", 'GET');
if ($userNotifsRes['status'] == 200 && is_array($userNotifsRes['data'])) {
    foreach ($userNotifsRes['data'] as $notif) {
        $notifications[] = [
            'type' => $notif['type'],
            'id' => $notif['id'],
            'message' => $notif['message'],
            'timestamp' => $notif['created_at']
        ];
    }
}

echo json_encode(['status' => 'success', 'data' => $notifications]);
?>
