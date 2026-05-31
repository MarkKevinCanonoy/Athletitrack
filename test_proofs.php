<?php
require 'config.php';
$res = supabase_request('/rest/v1/proofs?select=*', 'GET');
echo json_encode($res);
?>
