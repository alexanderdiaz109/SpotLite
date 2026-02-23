
$evals = Invoke-RestMethod -Uri "https://spotlight-api-m2kt.onrender.com/api/Evaluations" -Method Get
$evals[-1] | ConvertTo-Json -Depth 5

