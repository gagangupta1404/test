param(
	[parameter(Mandatory=$true)] [string] $apiPath, # The exact API URL suffix
	[parameter(Mandatory=$false)] [switch] $privateTemplateCreator = $false # The exact API URL suffix
)

## Test if the user is already logged in; otherwise login first
$token = armclient token
If ($token[0] -ne '{')
{
    armclient login
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($privateTemplateCreator -eq $true)
{
    Import-Module ..\..\..\..\deploy\APIManagementTemplate.dll
}
else
{
    ## Install template creator if not exists. See https://github.com/MLogdberg/APIManagementARMTemplateCreator
    if (Get-Module -ListAvailable -Name APIManagementTemplate) {
        Write-Host "PowerShell module 'APIManagementTemplate' already installed."
        Write-Host "Skipping installation"
    } 
    else {
        Write-Host "PowerShell module 'APIManagementTemplate' not found, start installation."
        Install-Module -Name APIManagementTemplate -Force -Scope CurrentUser
    }
}

$subscriptionId = '0af70dac-a1c3-49b9-913e-41d1d2168474'
$resourceGroup = 'rg-infra-hfg'
$apimInstance = 'mb-apim-ci'
$apiFilter = "path eq '$apiPath'"

Write-Host "Start API Management Template extraction."
armclient token $subscriptionId | Get-APIManagementTemplate -APIFilters $apiFilter -APIManagement $apimInstance -ResourceGroup $resourceGroup -SubscriptionId $subscriptionId -ExportPIManagementInstance $false -ExportGroups $false -FixedServiceNameParameter $true -ExportTags $true -ExportProducts $false -ParametrizePropertiesOnly $true -SeparatePolicyOutputFolder Policies | Out-File -Encoding utf8 infra-apim-configuration.json
Write-Host "Finished API Management Template extraction."