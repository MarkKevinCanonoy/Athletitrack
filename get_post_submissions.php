<?php
require_once 'config.php';
header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];
$team_id = $inputData['team_id'] ?? '';
$post_id = $inputData['post_id'] ?? '';

if (empty($team_id) || empty($post_id)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing team_id or post_id']);
    exit();
}

// 1. Get approved athletes for the team
$athletesRes = supabase_request("/rest/v1/team_members?team_id=eq." . urlencode($team_id) . "&status=eq.approved&select=athlete_id,users!athlete_id(full_name)", 'GET');
$athletes = $athletesRes['status'] == 200 ? $athletesRes['data'] : [];

// 2. Get proofs for this post
$proofsRes = supabase_request("/rest/v1/proofs?post_id=eq." . urlencode($post_id) . "&select=*", 'GET');
$proofs = $proofsRes['status'] == 200 ? $proofsRes['data'] : [];

// Map proofs by athlete (if multiple, grab the latest one by created_at)
$athleteProofs = [];
foreach ($proofs as $p) {
    $a_id = $p['athlete_id'];
    if (!isset($athleteProofs[$a_id])) {
        $athleteProofs[$a_id] = [];
    }
    $athleteProofs[$a_id][] = $p;
}

$submissions = [];
foreach ($athletes as $athlete) {
    $a_id = $athlete['athlete_id'];
    $name = $athlete['users']['full_name'];
    
    // Find latest proof for this athlete
    $status = 'missing';
    $latestProof = null;
    if (!empty($athleteProofs[$a_id])) {
        usort($athleteProofs[$a_id], function($a, $b) {
            return strtotime($b['submitted_at']) - strtotime($a['submitted_at']);
        });
        $latestProof = $athleteProofs[$a_id][0];
        $status = $latestProof['status'];
    }
    
    $submissions[] = [
        'athlete_id' => $a_id,
        'name' => $name,
        'status' => $status,
        'proof' => $latestProof
    ];
}

// Sort: Pending first, then missing, then approved/rejected
usort($submissions, function($a, $b) {
    $order = ['pending' => 1, 'missing' => 2, 'rejected' => 3, 'approved' => 4];
    return $order[$a['status']] - $order[$b['status']];
});

echo json_encode(['status' => 'success', 'submissions' => $submissions]);
