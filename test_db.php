<?php require 'config.php'; print_r(supabase_request('/rest/v1/proofs?select=*', 'GET')); ?>
