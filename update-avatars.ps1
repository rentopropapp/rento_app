# PowerShell script to add updateUserAvatar calls to HTML pages
$files = @(
    "tenant\home.html",
    "tenant\payments.html", 
    "tenant\profile.html",
    "broker\wallet.html",
    "broker\profile.html",
    "property-manager\dashboard.html",
    "property-manager\properties.html",
    "property-manager\property-dashboard.html",
    "property-manager\home.html",
    "property-manager\bookings.html",
    "property-manager\complaints.html",
    "property-manager\finances.html",
    "property-manager\maintenance.html",
    "property-manager\messages.html",
    "property-manager\tenants.html"
)

foreach ($file in $files) {
    $fullPath = "C:\Users\kakkr\.cursor\rento-app\$file"
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        
        # Pattern 1: Replace profile_photo_url checks
        $pattern1 = "(\s+)//\s*Update profile image if available\s*\r?\n\s+if\s*\(\s*currentUser\.profile_photo_url\s*\)\s*\{\s*\r?\n\s+document\.getElementById\('userAvatar'\)\.src\s*=\s*currentUser\.profile_photo_url;\s*\r?\n\s+\}"
        $replacement1 = '$1// Update user avatar with profile photo or initials' + "`r`n" + '$1updateUserAvatar(currentUser);'
        
        # Pattern 2: Replace userInitials updates
        $pattern2 = "(\s+)//\s*Update user initials\s*\r?\n\s+if\s*\(\s*currentUser\.name\s*\)\s*\{\s*\r?\n\s+const initials = currentUser\.name\.split\(' '\)\.map\(n => n\[0\]\)\.join\(''\)\.toUpperCase\(\);\s*\r?\n\s+document\.getElementById\('userInitials'\)\.textContent = initials;\s*\r?\n\s+\}"
        $replacement2 = '$1// Update user avatar with profile photo or initials' + "`r`n" + '$1updateUserAvatar(currentUser);'
        
        $updated = $false
        
        if ($content -match $pattern1) {
            $content = $content -replace $pattern1, $replacement1
            $updated = $true
        }
        
        if ($content -match $pattern2) {
            $content = $content -replace $pattern2, $replacement2
            $updated = $true
        }
        
        if ($updated) {
            Set-Content $fullPath -Value $content -NoNewline
            Write-Host "Updated $file"
        }
    }
}

Write-Host "Avatar update script completed"