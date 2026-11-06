# Optional PRIVATE staging helper. Does not upload any files.
# Review/redact images manually before adding to evidence/reviewed/.
$Source = 'C:\Users\bazzi\Desktop\ServiceNow_HelpDesk_Lab_2026\09_Screenshots'
$Destination = Join-Path $HOME 'Desktop\Northstar-Evidence-PRIVATE-Review'
if (-not (Test-Path $Source)) { throw "Source evidence folder not found: $Source" }
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$Files = Get-ChildItem $Source -File -Filter 'SNOW-*.png'
foreach ($File in $Files) {
    Copy-Item -LiteralPath $File.FullName -Destination (Join-Path $Destination $File.Name) -ErrorAction Stop
}
Write-Host "Copied $($Files.Count) original images to private staging folder: $Destination"
Write-Warning 'PRIVATE STAGING ONLY. Manually inspect/redact before publishing any evidence.'
