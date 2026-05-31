$body = @{ team_id = 'eff61e30-6318-4176-94c3-a1f173109227' } | ConvertTo-Json
$response = Invoke-RestMethod -Uri 'http://localhost/athletitrack-api/get_attendance.php' -Method Post -Body $body -ContentType 'application/json'
$response | ConvertTo-Json -Depth 5
