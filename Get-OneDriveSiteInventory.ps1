
function Get-WebDetails {
    param(
        $Web,
        $Connection,
        $ClientId,
        $SiteId,
        $SiteOwnerEmail,
        $ReportOutput
    )
    Get-PnPProperty -ClientObject $Web -Property ParentWeb,LastItemUserModifiedDate,LastItemModifiedDate
    $WebDatum = New-Object PSObject
    $WebDatum | Add-Member NoteProperty Url($Web.Url)
    $WebDatum | Add-Member NoteProperty WebId($Web.Id)
    $WebDatum | Add-Member NoteProperty WebTitle($Web.Title)
    $WebDatum | Add-Member NoteProperty SiteId($SiteId)
    $WebDatum | Add-Member NoteProperty LastItemUserModifiedDate($Web.LastItemModifiedDate)
    $WebDatum | Add-Member NoteProperty LastItemModifiedDate($Web.LastItemUserModifiedDate)
    $WebDatum | Add-Member NoteProperty SiteOwnerEmail($SiteOwnerEmail)
    $WebData += $WebDatum
    $WebData | Export-Csv -Path $ReportOutput -NoTypeInformation -Append
}

function Get-SiteDetails {
    param(
        $ClientId,
        $Site,
        $ReportOutput
    )
    write-host $Site.url
    $SiteOwnerEmail = ($Site.Owner.LoginName -replace "i:0#\.f\|membership\|", "")
    $webs = Get-PnPSubWeb -Recurse
    $webs += Get-PnPWeb
    foreach ($w in $webs) {
    
        write-host "    connecting to $($w.url)"
        Get-WebDetails -web $w -Clientid $ClientId -SiteId $Site.Id -ReportOutput $ReportOutput -SiteOwnerEmail $SiteOwnerEmail
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
    write-host "connecting to spo admin"
    Connect-PnPOnline -Url $SPOAdminUrl `
            -ClientId $ClientId `
            -Tenant $Tenant `
            -CertificatePath $CertificatePath
    $SPOSites=Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"
    foreach ($s in $SPOSites) {
        write-host "  connecting to $($s.url)"
        Connect-PnPOnline -Url $s.url `
        -ClientId $ClientId `
        -Tenant $Tenant `
        -CertificatePath $CertificatePath
        $site=Get-PnPSite -Includes Id, Owner
        Get-SiteDetails -Site $site -ClientId $ClientId -ReportOutput $ReportOutput
    }
}


#Modify the variables below for your envionment
Get-SPOConnection -ClientId $ `
    -CertificatePath "<Path to Your Certificate>" `
    -Tenant "<Your tenant name>.onmicrosoft.com" `
    -SPOAdminUrl "https://<Your tenant name>-admin.sharepoint.com" `
    -ReportOutput "c:\temp\OneDriveInventory.csv"