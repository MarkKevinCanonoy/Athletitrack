<?php
// C:\xampp\htdocs\athletitrack-api\config.php

// Enable CORS for Flutter web / mobile access
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: *");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database Configuration (Supabase)
// Replace these with your actual Supabase credentials once provided.
define('SUPABASE_URL', 'https://evxywzmtqhykhowypfmh.supabase.co');
define('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2eHl3em10cWh5a2hvd3lwZm1oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxNDM0ODksImV4cCI6MjA5NTcxOTQ4OX0.n7AMURzs7zH5xmSjHEPPLRiIc4Zfu7cHTNIs8hoxKEs');

// Email Configuration (Gmail SMTP)
// Enter your Gmail address and the 16-character App Password here.
define('SMTP_EMAIL', 'kevinixmarkix@gmail.com');
define('SMTP_APP_PASSWORD', 'eaih uypt mucu rapu');

// Utility function to make API calls to Supabase REST endpoint
function supabase_request($endpoint, $method = 'GET', $data = null, $customHeaders = []) {
    $url = SUPABASE_URL . $endpoint;
    
    $headers = [
        "apikey: " . SUPABASE_KEY,
        "Authorization: Bearer " . SUPABASE_KEY,
        "Prefer: return=representation"
    ];
    
    $contentType = "application/json";
    foreach ($customHeaders as $chdr) {
        if (stripos($chdr, 'Content-Type:') === 0) {
            $contentType = trim(substr($chdr, 13));
        }
    }
    $headers[] = "Content-Type: " . $contentType;

    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        if ($data !== null) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, ($contentType === 'application/json') ? json_encode($data) : $data);
        }
    } else if ($method === 'PATCH') {
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
        if ($data !== null) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, ($contentType === 'application/json') ? json_encode($data) : $data);
        }
    } else if ($method === 'DELETE') {
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'status' => $httpCode,
        'data' => json_decode($response, true)
    ];
}
?>
