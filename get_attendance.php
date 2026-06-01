<?php
require_once 'config.php';

header("Content-Type: application/json; charset=UTF-8");

$inputData = json_decode(file_get_contents("php://input"), true) ?? [];
if (empty($inputData['team_id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing team_id.']);
    exit();
}

$team_id = $inputData['team_id'];

// 1. Get approved athletes
$athletesRes = supabase_request("/rest/v1/team_members?team_id=eq." . urlencode($team_id) . "&status=eq.approved&select=athlete_id,skill_level,users!athlete_id(full_name)", 'GET');
$athletes = $athletesRes['status'] == 200 ? $athletesRes['data'] : [];

// 2. Get training posts
$postsRes = supabase_request("/rest/v1/posts?team_id=eq." . urlencode($team_id) . "&type=eq.training&select=id,title,session_date,is_weekly,days_of_week,created_at", 'GET');
$posts = $postsRes['status'] == 200 ? $postsRes['data'] : [];

// 3. Get proofs for these posts
// To avoid too long URL, we get all proofs for athletes in this team.
// First get a list of athlete IDs
$athleteIds = array_column($athletes, 'athlete_id');
if (empty($athleteIds)) {
    echo json_encode(['status' => 'success', 'columns' => [], 'rows' => []]);
    exit();
}

// Get proofs
$proofsRes = supabase_request("/rest/v1/proofs?select=*", 'GET'); // Simplified, in production should filter by post_id or athlete_id
$allProofs = $proofsRes['status'] == 200 ? $proofsRes['data'] : [];

// Filter proofs to only those belonging to the team's athletes and posts
$postIds = array_column($posts, 'id');
$proofs = array_filter($allProofs, function($p) use ($postIds, $athleteIds) {
    return in_array($p['post_id'], $postIds) && in_array($p['athlete_id'], $athleteIds);
});

// 4. Generate Columns (Sessions)
$columns = [];
$today = new DateTime();
$today->setTime(0, 0, 0);

$dayMap = [
    'Mon' => 1, 'Tue' => 2, 'Wed' => 3, 'Thu' => 4, 'Fri' => 5, 'Sat' => 6, 'Sun' => 7,
    'M' => 1, 'T' => 2, 'W' => 3, 'Th' => 4, 'F' => 5, 'S' => 6, 'Su' => 7
];

foreach ($posts as $post) {
    if (!$post['is_weekly']) {
        if (!empty($post['session_date'])) {
            $columns[] = [
                'post_id' => $post['id'],
                'date' => $post['session_date'],
                'title' => $post['title']
            ];
        }
    } else {
        // Weekly schedule
        $created = new DateTime($post['created_at']);
        $created->setTime(0, 0, 0);
        
        $daysOfWeek = array_map('trim', explode(',', $post['days_of_week'] ?? ''));
        $targetDays = [];
        foreach ($daysOfWeek as $d) {
            if (isset($dayMap[$d])) $targetDays[] = $dayMap[$d];
        }
        
        $current = clone $created;
        while ($current <= $today) {
            $dayOfWeek = (int)$current->format('N');
            if (in_array($dayOfWeek, $targetDays)) {
                $columns[] = [
                    'post_id' => $post['id'],
                    'date' => $current->format('Y-m-d'),
                    'title' => $post['title']
                ];
            }
            $current->modify('+1 day');
        }
    }
}

// Sort columns by date
usort($columns, function($a, $b) {
    return strcmp($a['date'], $b['date']);
});

// 5. Map Proofs to Athlete x Column
$rows = [];
foreach ($athletes as $athlete) {
    $row = [
        'athlete_id' => $athlete['athlete_id'],
        'name' => $athlete['users']['full_name'],
        'skill_level' => $athlete['skill_level'] ?? 'Intermediate',
        'attendance' => [] // key: post_id_date, value: proof status
    ];
    
    foreach ($columns as $col) {
        $colKey = $col['post_id'] . '_' . $col['date'];
        
        // Find if this athlete has a proof for this post on this date
        $status = 'missing'; // default
        $proofId = null;
        $fileUrl = null;
        $isExcuse = false;
        $comment = null;
        $coachNote = null;
        $submittedAt = null;
        
        foreach ($proofs as $p) {
            if ($p['athlete_id'] == $athlete['athlete_id'] && $p['post_id'] == $col['post_id']) {
                $subDate = substr($p['submitted_at'], 0, 10);
                
                $postIsWeekly = false;
                foreach($posts as $po) {
                    if($po['id'] == $col['post_id']) $postIsWeekly = $po['is_weekly'];
                }

                if (!$postIsWeekly || $subDate === $col['date']) {
                    $status = $p['status']; // 'pending', 'approved', 'rejected'
                    $proofId = $p['id'];
                    $fileUrl = $p['file_url'];
                    $isExcuse = $p['is_excuse'];
                    $comment = $p['comment'];
                    $coachNote = $p['coach_note'] ?? null;
                    $submittedAt = $p['submitted_at'] ?? null;
                    break;
                }
            }
        }
        
        $row['attendance'][] = [
            'col_key' => $colKey,
            'status' => $status,
            'proof_id' => $proofId,
            'file_url' => $fileUrl,
            'is_excuse' => $isExcuse,
            'comment' => $comment,
            'coach_note' => $coachNote,
            'submitted_at' => $submittedAt
        ];
    }
    
    $rows[] = $row;
}

echo json_encode(['status' => 'success', 'columns' => $columns, 'rows' => $rows]);
?>
