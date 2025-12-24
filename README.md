# Remove M365 Licenses from Disabled Users

This PowerShell script removes Microsoft 365 licenses from disabled users in Entra ID using the Microsoft Graph PowerShell SDK.

It is designed to help maintain license hygiene by ensuring disabled accounts do not continue to consume paid licenses.

---

## Features

- Identifies all disabled Entra ID users
- Removes all assigned licenses
- Dry-run mode enabled by default
- Uses Microsoft Graph (supported API)
- Simple and safe to run
- Suitable for automation and scheduling

---

## Prerequisites

- PowerShell 7+
- Microsoft Graph PowerShell SDK
- Entra ID role:
  - User Administrator or Global Administrator

Install Microsoft Graph PowerShell (once):

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
