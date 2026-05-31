<?php
function log_error($msg) {
    file_put_contents('debug.log', date('Y-m-d H:i:s') . " - " . print_r($msg, true) . "\n", FILE_APPEND);
}
log_error("--- UPLOAD PROOF DEBUG ---");
log_error($_FILES);
log_error($_POST);
?>
