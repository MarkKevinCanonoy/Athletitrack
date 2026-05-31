<?php
require 'config.php';
$reqsRes = supabase_request("/rest/v1/team_members?status=eq.pending&select=id,athlete_id,team_id,teams(name),users(full_name)&order=created_at.desc", 'GET');
print_r($reqsRes);
?>
