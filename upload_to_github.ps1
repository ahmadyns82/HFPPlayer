# ============================================================
# HFPPlayer — Upload all files to GitHub via API
# Usage: Right-click → Run with PowerShell
#        OR: powershell -ExecutionPolicy Bypass -File upload_to_github.ps1
# ============================================================

param(
    [string]$Token   = "",   # Your GitHub Personal Access Token
    [string]$Owner   = "ahmadyns82",
    [string]$Repo    = "HFPPlayer",
    [string]$Branch  = "main"
)

# ── Ask for token if not provided ────────────────────────────
if (-not $Token) {
    Write-Host ""
    Write-Host "Enter your GitHub Personal Access Token" -ForegroundColor Cyan
    Write-Host "(GitHub.com → Settings → Developer settings → Personal access tokens → Classic)" -ForegroundColor Gray
    Write-Host "Token needs: repo (full control)" -ForegroundColor Gray
    Write-Host ""
    $Token = Read-Host "Paste token here"
}

$Headers = @{
    Authorization = "token $Token"
    Accept        = "application/vnd.github.v3+json"
    "User-Agent"  = "HFPPlayer-Uploader"
}

$BaseUrl = "https://api.github.com/repos/$Owner/$Repo"

# ── Verify token works ────────────────────────────────────────
Write-Host ""
Write-Host "Verifying token..." -ForegroundColor Yellow
try {
    $user = Invoke-RestMethod "https://api.github.com/user" -Headers $Headers
    Write-Host "Logged in as: $($user.login)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Token invalid or no repo access." -ForegroundColor Red
    Write-Host $_.Exception.Message
    Read-Host "Press Enter to exit"
    exit 1
}

# ── Get or create default branch SHA ─────────────────────────
Write-Host "Getting repo info..." -ForegroundColor Yellow
$sha = $null
try {
    $ref = Invoke-RestMethod "$BaseUrl/git/ref/heads/$Branch" -Headers $Headers
    $sha = $ref.object.sha
    Write-Host "Branch '$Branch' exists, SHA: $sha" -ForegroundColor Green
} catch {
    Write-Host "Branch '$Branch' not found — will create on first push." -ForegroundColor Yellow
}

# ── Collect all files to upload ──────────────────────────────
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$AllFiles   = Get-ChildItem -Path $ScriptDir -Recurse -File |
              Where-Object {
                  $_.FullName -notmatch '\\.git\\' -and
                  $_.Name -ne 'upload_to_github.ps1' -and
                  $_.Name -ne 'push_to_github.sh'
              }

Write-Host ""
Write-Host "Files to upload: $($AllFiles.Count)" -ForegroundColor Cyan
$AllFiles | ForEach-Object {
    $rel = $_.FullName.Substring($ScriptDir.Length + 1).Replace('\', '/')
    Write-Host "  $rel" -ForegroundColor Gray
}

Write-Host ""
$confirm = Read-Host "Upload all $($AllFiles.Count) files to github.com/$Owner/$Repo ? (y/n)"
if ($confirm -ne 'y') { Write-Host "Cancelled."; exit 0 }

# ── Upload each file ─────────────────────────────────────────
$success = 0
$fail    = 0

foreach ($file in $AllFiles) {
    $relPath = $file.FullName.Substring($ScriptDir.Length + 1).Replace('\', '/')
    $content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($file.FullName))
    $apiUrl  = "$BaseUrl/contents/$relPath"

    # Check if file already exists (need its SHA to update)
    $existingSha = $null
    try {
        $existing    = Invoke-RestMethod $apiUrl -Headers $Headers
        $existingSha = $existing.sha
    } catch {}

    $body = @{
        message = "ci: upload $relPath"
        content = $content
        branch  = $Branch
    }
    if ($existingSha) { $body.sha = $existingSha }

    try {
        Invoke-RestMethod $apiUrl -Method PUT -Headers $Headers `
            -Body (ConvertTo-Json $body -Depth 3) | Out-Null
        Write-Host "  ✓ $relPath" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "  ✗ $relPath — $($_.Exception.Message)" -ForegroundColor Red
        $fail++
    }
}

# ── Done ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!  ✓ $success uploaded   ✗ $fail failed" -ForegroundColor $(if ($fail -eq 0) {"Green"} else {"Yellow"})
Write-Host ""
Write-Host "Check: https://github.com/$Owner/$Repo" -ForegroundColor Cyan
Write-Host ""
Write-Host "You should see HFPPlayer.xcodeproj/ as a folder." -ForegroundColor White
Write-Host "Then go to Codemagic and start a new build." -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close"
