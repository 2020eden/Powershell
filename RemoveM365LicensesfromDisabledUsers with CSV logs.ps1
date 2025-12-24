<#
.SYNOPSIS
Removes Microsoft 365 licenses from disabled Entra ID users.

.DESCRIPTION
Uses Microsoft Graph with Managed Identity to remove all assigned
licenses from disabled users. Supports dry-run mode and CSV logging.

.AUTHOR
Verdieu Eden
#>

# ================= CONFIGURATION =================
$DryRun = $true   # Set to $false to remove licenses
# =================================================

Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Connect to Microsoft Graph using Managed Identity
Connect-MgGraph -Identity

Write-Output "Connected to Microsoft Graph using Managed Identity."

$Log = @()

# Get disabled users with licenses
$DisabledUsers = Get-MgUser -All `
    -Filter "accountEnabled eq false" `
    -Property Id,DisplayName,UserPrincipalName,AssignedLicenses |
    Where-Object { $_.AssignedLicenses.Count -gt 0 }

Write-Output "Found $($DisabledUsers.Count) disabled users with licenses."

foreach ($User in $DisabledUsers) {

    $LicenseIds = $User.AssignedLicenses.SkuId
    $Result = ""

    if ($DryRun) {
        $Result = "DryRun - No changes"
        Write-Output "[DRY RUN] $($User.UserPrincipalName) | Licenses: $($LicenseIds.Count)"
    }
    else {
        try {
            Set-MgUserLicense `
                -UserId $User.Id `
                -AddLicenses @() `
                -RemoveLicenses $LicenseIds

            $Result = "Licenses removed"
            Write-Output "Removed $($LicenseIds.Count) licenses from $($User.UserPrincipalName)"
        }
        catch {
            $Result = "ERROR: $($_.Exception.Message)"
            Write-Error "Failed for $($User.UserPrincipalName)"
        }
    }

    $Log += [PSCustomObject]@{
        TimeStamp         = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        DisplayName       = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
        LicenseCount      = $LicenseIds.Count
        Result            = $Result
    }
}

# Output CSV to runbook logs
$CsvOutput = $Log | ConvertTo-Csv -NoTypeInformation
Write-Output "`n===== CSV LOG START ====="
$CsvOutput | ForEach-Object { Write-Output $_ }
Write-Output "===== CSV LOG END ====="

Disconnect-MgGraph
Write-Output "Disconnected from Microsoft Graph."
