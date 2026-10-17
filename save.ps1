# Commit every change in this folder and push it to GitHub.
# Usage: .\save.ps1            (auto message with timestamp)
#        .\save.ps1 "message"  (your own message)
param([string]$Message)

Set-Location $PSScriptRoot

# Use git from PATH, else the copy bundled with GitHub Desktop (newest version).
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) {
  $git = Get-ChildItem "$env:LOCALAPPDATA\GitHubDesktop\app-*\resources\app\git\cmd\git.exe" -ErrorAction SilentlyContinue |
    Sort-Object { [version]($_.FullName -replace '.*\\app-([\d.]+)\\.*', '$1') } -Descending |
    Select-Object -First 1 -ExpandProperty FullName
}
if (-not $git) { Write-Error 'git not found. Install Git or GitHub Desktop.'; exit 1 }

& $git add -A
& $git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Output 'Nothing to save.'; exit 0 }

if (-not $Message) { $Message = "Auto-save $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
& $git commit -q -m $Message
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $git push -q
if ($LASTEXITCODE -ne 0) { Write-Error 'Push to GitHub failed.'; exit $LASTEXITCODE }
Write-Output "Saved to GitHub: $Message"
