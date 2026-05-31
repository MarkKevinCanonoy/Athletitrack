<?php
require 'config.php';
$team_id = 'eff61e30-6318-4176-94c3-a1f173109227';
$postsRes = supabase_request("/rest/v1/posts?team_id=eq." . urlencode($team_id) . "&type=eq.training&select=id,title,session_date,is_weekly,days_of_week,created_at", 'GET');
print_r($postsRes['data']);
?>
