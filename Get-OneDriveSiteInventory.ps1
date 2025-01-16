
function Get-WebDetails {
    param(
        $Web,
        $Connection,
        $ClientId,
        $SiteId,
        $SiteOwnerUPN,
        $SiteSize,
        $ReportOutput
    )
    Write-Host "$(Get-Date) ----Processing Web: $($Web.Title)"
    Get-PnPProperty -ClientObject $Web -Property ParentWeb,LastItemUserModifiedDate,LastItemModifiedDate
    $docs=get-pnplist "Documents"
    $WebDatum = New-Object PSObject
    $WebDatum | Add-Member NoteProperty Url($Web.Url)
    $WebDatum | Add-Member NoteProperty WebId($Web.Id)
    $WebDatum | Add-Member NoteProperty WebTitle($Web.Title)
    $WebDatum | Add-Member NoteProperty SiteId($SiteId)
    $WebDatum | Add-Member NoteProperty LastItemUserModifiedDate($Web.LastItemModifiedDate)
    $WebDatum | Add-Member NoteProperty LastItemModifiedDate($Web.LastItemUserModifiedDate)
    $WebDatum | Add-Member NoteProperty SiteOwnerUPN($SiteOwnerUPN)
    $WebDatum | Add-Member NoteProperty SiteSize($SiteSize)
    $WebDatum | Add-Member NoteProperty DocumentCount($($docs.ItemCount))
    $WebData += $WebDatum
    $WebData | Export-Csv -Path $ReportOutput -NoTypeInformation -Append
}

function Get-SiteDetails {
    param(
        $ClientId,
        $Site,
        $ReportOutput
    )
    Write-Host "$(Get-Date) --Processing Site: $($Site.Url)"
    $SiteOwnerUPN = ($Site.Owner.LoginName -replace "i:0#\.f\|membership\|", "")
    $webs = Get-PnPSubWeb -Recurse
    $webs += Get-PnPWeb
    foreach ($w in $webs) {
        Get-WebDetails -web $w `
            -Clientid $ClientId `
            -SiteId $Site.Id `
            -ReportOutput $ReportOutput `
            -SiteOwnerUPN $SiteOwnerUPN `
            -SiteSize $Site.Usage.Storage
    }
}

function Get-SPOConnection {
    param(
        $ClientId, #App Only Registration
        $CertificatePath, #App Only Registration
        $Tenant,
        $SPOAdminUrl,
        $ReportOutput
    )
    Write-Host "$(Get-Date) Connecting to SPO Admin"
    Connect-PnPOnline -Url $SPOAdminUrl `
            -ClientId $ClientId `
            -Tenant $Tenant `
            -CertificatePath $CertificatePath
    $SPOSites=Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"
    foreach ($s in $SPOSites) {
        Connect-PnPOnline -Url $s.url `
        -ClientId $ClientId `
        -Tenant $Tenant `
        -CertificatePath $CertificatePath
        $site=Get-PnPSite -Includes Id,Owner,Usage
        Get-SiteDetails -Site $site -ClientId $ClientId -ReportOutput $ReportOutput
    }
}


<#Modify the variables below for your envionment
Get-SPOConnection -ClientId $ `
    -CertificatePath "<Path to Your Certificate>" `
    -Tenant "<Your tenant name>.onmicrosoft.com" `
    -SPOAdminUrl "https://<Your tenant name>-admin.sharepoint.com" `
    -ReportOutput "c:\temp\OneDriveInventory.csv"

    #>