<?php
require 'config.php';
$team_id = 'eff61e30-6318-4176-94c3-a1f173109227';
$inputData = json_encode(['team_id' => $team_id]);
file_put_contents('php://memory', $inputData);

// Simulate POST input
$_SERVER['REQUEST_METHOD'] = 'POST';

$url = 'http://localhost/athletitrack-api/get_attendance.php';
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $inputData);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
curl_close($ch);

echo $response;
?>
