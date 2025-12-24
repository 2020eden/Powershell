# ==============================
# Remove M365 Licenses from Disabled Users
# ==============================

# Set to $true to simulate, $false to actually remove licenses
$DryRun = $true  

# Required Graph scopes
$Scopes = @(
    "User.ReadWrite.All",
    "Directory.ReadWrite.All"
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes $Scopes

Write-Host "`nFetching disabled users..." -ForegroundColor Cyan

# Get all disabled users with licenses
$DisabledUsers = Get-MgUser -All `
    -Filter "accountEnabled eq false" `
    -Property Id,DisplayName,UserPrincipalName,AssignedLicenses

$DisabledUsers = $DisabledUsers | Where-Object {
    $_.AssignedLicenses.Count -gt 0
}

if ($DisabledUsers.Count -eq 0) {
    Write-Host "No disabled users with licenses found." -ForegroundColor Green
    return
}

foreach ($User in $DisabledUsers) {

    $LicenseIds = $User.AssignedLicenses.SkuId

    if ($DryRun) {
        Write-Host "[DRY RUN] Would remove $($LicenseIds.Count) license(s) from $($User.UserPrincipalName)" -ForegroundColor Yellow
    }
    else {
        Set-MgUserLicense `
            -UserId $User.Id `
            -AddLicenses @() `
            -RemoveLicenses $LicenseIds

        Write-Host "Removed $($LicenseIds.Count) license(s) from $($User.UserPrincipalName)" -ForegroundColor Green
    }
}

Write-Host "`nScript completed." -ForegroundColor Cyan
