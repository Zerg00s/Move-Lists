param (
    [string]$Path
)

#-----------------------------------------------------------------------
# Script lets you migrate one or more SharePoint lists from source site
# To destination site
# Denis Molodtsov, 2021
#-----------------------------------------------------------------------

$ErrorActionPreference = "Stop"

Clear-Host

Write-Host $Path -ForegroundColor Green

Set-Location $Path
. .\MISC\PS-Forms.ps1

Get-ChildItem -Recurse | Unblock-File
# Legacy PowerShell PnP Module is used because the new one has a critical bug
Import-Module (Get-ChildItem -Recurse -Filter "*.psd1").FullName -DisableNameChecking

$Migration = @{
    Source_Site = "https://contoso.sharepoint.com/sites/Site_A"
    Target_Site = "https://contoso.sharepoint.com/sites/Site_b"
    Lists       = ""
}

$Migration = Get-FormItemProperties -item $Migration -dialogTitle "Enter source and target sites" -propertiesOrder @("Source_Site", "Target_Site", "Lists") -note "List titles are comma-separated. Leave blank to have an interactive selector"

Connect-PnPOnline -Url $Migration.Source_Site -UseWebLogin -WarningAction Ignore

if ($Migration.Lists) {
    $titles = $Migration.Lists.Split(",")
}
else {
    $lists = Get-PnPList
    $lists = $lists | Where-Object { $_.Hidden -eq $false }
    
    $selectedLists = Get-FormArrayItems ($lists) -dialogTitle "Select lists and libraries to migrate" -key Title
    $titles = $selectedLists.Title

    # If a list contains custom content types, we will have to move them all.
    $exportContentTypes = $false
    foreach ($list in $selectedLists) {
        $listContentTypes = Get-PnPContentType -List $list         
        $context = $list.Context        
        foreach ($contentType in $listContentTypes) {
            $context.Load($contentType)
            $context.ExecuteQuery()  
            [xml]$xml = $contentType.SchemaXml 
            if ($null -eq $xml.ContentType.FeatureId) {
                $exportContentTypes = $true;
            }
        }
    } 
}

if ($exportContentTypes) {
    Get-pnpProvisioningTemplate -ListsToExtract $titles -Out "Lists.xml" -Handlers Lists, ContentTypes, Fields -Force -WarningAction Ignore 
}
else {
    Get-pnpProvisioningTemplate -ListsToExtract $titles -Out "Lists.xml" -Handlers Lists -Force -WarningAction Ignore 
}

((Get-Content -path Lists.xml -Raw) -replace 'RootSite', 'Web') | Set-Content -Path Lists.xml

foreach ($title in $titles) {
    # Get the latest list item form layout. Footer, Header and the Body:
    $list = Get-PnPList $title -Includes ContentTypes
    $contentType = $list.ContentTypes | Where-Object { $_.Name -eq "Item" }
    $contentType.ClientFormCustomFormatter | Set-Content .\$title.json
}

Disconnect-PnPOnline

Connect-PnPOnline -Url $Migration.Target_Site -UseWebLogin
Apply-PnPProvisioningTemplate -Path Lists.xml 

foreach ($title in $titles) {
    $list = Get-PnPList $title -Includes ContentTypes
    $contentType = $list.ContentTypes | Where-Object { $_.Name -eq "Item" }
    if ($contentType) {
        $json = Get-Content .\$title.json
        $contentType.ClientFormCustomFormatter = $json
        $contentType.Update($false)
        $contentType.Context.ExecuteQuery();
    }
}

Write-Host "" 
Write-Host "Target site" $($Migration.Target_Site + "/_layouts/15/viewlsts.aspx") -ForegroundColor Yellow

$Url_To_Open = ($Migration.Target_Site + "/_layouts/15/viewlsts.aspx")
Start-Process $Url_To_Open