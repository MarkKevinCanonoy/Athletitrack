<?php

require_once __DIR__ . '/../vendor/autoload.php';

use App\Api\AuthController;
use App\Api\TeamController;

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Parse incoming JSON payload
$inputData = json_decode(file_get_contents("php://input"), true) ?? [];

// Helper to match endpoints regardless of base folder
function matchRoute($uri, $endpoint) {
    // Check if the URI ends with the endpoint exactly
    return (substr($uri, -strlen($endpoint)) === $endpoint);
}

// Simple routing
if (matchRoute($uri, '/api/auth/register') && $method === 'POST') {
    (new AuthController())->register($inputData);
} elseif (matchRoute($uri, '/api/auth/verify') && $method === 'POST') {
    (new AuthController())->verifyOtp($inputData);
} elseif (matchRoute($uri, '/api/teams/create') && $method === 'POST') {
    (new TeamController())->createTeam($inputData);
} elseif (matchRoute($uri, '/api/teams/list') && $method === 'POST') {
    (new TeamController())->listCoachTeams($inputData);
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found: ' . $uri]);
}
