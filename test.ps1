$json = Get-Content -Raw -LiteralPath 'C:\Users\dejunai\projects\repo\KB0RXF\acf-v3-bulletproof.json'
$group = $json | ConvertFrom-Json
$group.fields | ForEach-Object { $_.name }
