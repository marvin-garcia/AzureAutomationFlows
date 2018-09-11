configuration InstallPackage
{
   param 
    ( 
        [parameter(Mandatory)]
        [String] $PackageUrl,

        [parameter(Mandatory)]
        [String] $PackageName,

        [parameter(Mandatory)]
        [String] $PackageExtension,
        
        [parameter(Mandatory)]
        [String] $PackageId,

        [parameter(Mandatory)]
        [String] $Arguments,

        [parameter(Mandatory=$false)]
        [pscredential] $Credentials
    ) 

    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName cRemoteFile
    
    $installPath = "C:\Windows\Temp\$($PackageName)"
    $logPath = "$($installPath)\logs"
    
    Node localhost
    {
        # WindowsFeature InstallWindowsFeature
        # {
        #     Ensure = "Present"
        #     Name = "Feature-Name"
        # }

        File CreatePackageFolder
        {
            Ensure = "Present"
            DestinationPath = $installPath
            Type = "Directory"
        }

        cRemoteFile DownloadPackage
        {
            # DependsOn = "[WindowsFeature]InstallWindowsFeature;[File]CreatePackageFolder"
            DependsOn = "[File]CreatePackageFolder"
            Uri = $PackageUrl
            DestinationPath = "$installPath\$($PackageName).$($PackageExtension)"
        }

        Package InstallPackage
        {
            DependsOn = "[cRemoteFile]DownloadPackage"
            Ensure = "Present"
            Name = $PackageName
            ProductId = $PackageId
            Path = "$installPath\$($PackageName).$($PackageExtension)"
            Arguments = $Arguments
            LogPath = "$logPath\$($PackageName).log"
        }

        File RemovePackageFile
        {
            DependsOn = "[Package]InstallPackage"
            Ensure = "Absent"
            DestinationPath = "$installPath\$($PackageName).$($PackageExtension)"
        }
    }
}