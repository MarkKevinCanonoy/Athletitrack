<?php
require "config.php";
$res = supabase_request("/rest/v1/teams?select=*,team_members(count),posts(id,title,session_date,session_time,is_weekly,days_of_week)", "GET");
print_r($res["data"]);
?>
