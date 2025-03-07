# Overview

This script inventories OneDrive sites, collecting information about the site size and last user item modified date to help understand which OneDrive sites are still active.

# Script Reference

| Script | Description | Permissions Required | Dependencies | 
| --- | --- | --- | --- |
| Get-OneDriveSiteInventory.ps1 | Iterates through OneDrive Sites to Collect Details | see below | PnP PowerShell

# PowerShell Requirements

*   [Windows PowerShell 7.0 or higher](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4)
*   [PnP.PowerShell module 2.99.74 or higher](https://pnp.github.io/powershell/articles/installation.html)
*   [Entra ID Application Registered to use with PnP PowerShell](https://pnp.github.io/powershell/articles/registerapplication)

# Script Details

### Permissions Required

| API | Type | Permission | Justification |
| --- | --- | --- | --- |
| SharePoint | Application | Sites.FullControl.All | Required to retrieve tenant site properties. |
| Microsoft Graph | Application | User.ReadWriteAll | Required to retrieve User Details from Graph |

# Example

```powershell
# Example: Basic usage with required parameters
Get-SPOConnection -ClientId "your-client-id" `
    -CertificatePath "path-and-file-name-to-your-certificate.pfx" `
    -Tenant "your-tenant-name.onmicrosoft.com" `
    -SPOAdminUrl "https://your-tenant-name-admin.sharepoint.com" `
    -ReportOutput "path-and-file-name-to-your-output-csv.csv"
```