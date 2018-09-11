param
(
    [Parameter(Mandatory=$true)]
    [string]
    $TemplatePath,

    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]
    $Location,

    [Parameter(Mandatory=$true)]
    [string]
    $DnsLabelPrefix,

    [Parameter(Mandatory=$true)]
    [string]
    $VmName,

    [Parameter(Mandatory=$true)]
    [string]
    $AdminUsername,

    [Parameter(Mandatory=$true)]
    [string]
    $AdminPassword,

    [Parameter(Mandatory=$false)]
    [int]
    $RdpPort = 5001,

    [Parameter(Mandatory=$false)]
    [string]
    $ArtifactsLocation = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-custom-script-windows",

    [Parameter(Mandatory=$false)]
    [string]
    $ArtifactsLocationSasToken = ""
)



# Authenticate to Azure if running from Azure Automation
$servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Connect-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Write-Verbose

#Set the parameter values for the Resource Manager template
$parameters = @{
    "DnsLabelPrefix " = $DnsLabelPrefix
    "VmName " = $VmName
    "AdminUsername " = $AdminUsername
    "AdminPassword " = $AdminPassword
    "RdpPort = 5001 " = $RdpPort
    "Location" = $Location
    "ArtifactsLocation" = $ArtifactsLocation
    "ArtifactsLocationSasToken" = $ArtifactsLocationSasToken
}

# Download template file
$templateFile = 'C:\Temp\Template.json'
$client = New-Object System.Net.WebClient
$client.DownloadFile($TemplatePath, $templateFile)

# Deploy the storage account
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -TemplateParameterObject $Parameters