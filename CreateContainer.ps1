#Set local variables 
#########################################################################################
$containerName = "BC-20-2-SE"                    #NAV/BC-Version-Build/CU-Localization
$type = 'OnPrem'                                #OnPrem or Sandbox (only for BC)

#########################################################################################
#Optional variables
$licenseFolder = 'C:\DOCKER\LICENSE'
$checkHelper = $false                               #innstall bccontainerhelper
$dvdPath = ''                                    #blank = use online artifacts 
$prototypeDVD = $true                             #true = use a prototype DVD
$bcUser = 'dt'
$password = 'Corp123!'


#Install internet libraries (needs PowerShell 3.0 or higher and admin privilege) 
################################################################################
Clear-Host

if ($checkHelper)
{    
    Write-Host 'Installing BcContainerHelper module, please wait...'
    install-module BcContainerHelper -force
    Get-InstalledModule BcContainerHelper | Format-List -Property name, version    
} 

#Create PSCredentials
#####################
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($bcUser, $securePassword)

#Process Prototype DVD
######################
if ($prototypeDVD -and ($dvdPath -ne ''))
{        
    Write-Host "Unblocking original ZIP file : $dvdPath" -ForegroundColor Cyan
    Unblock-File -Path $dvdPath
    
    Write-Host "Extracting original ZIP file : $dvdPath.TEMPDIR" -ForegroundColor Cyan
    Expand-Archive -Path $dvdPath -DestinationPath "$dvdPath.TEMPDIR"
    
    Write-Host "Delete Manifest file : $dvdPath.TEMPDIR" -ForegroundColor Cyan
    Get-ChildItem -Path "$dvdPath.TEMPDIR\" -Recurse -Filter '_Manifest' | Remove-Item -Force -Recurse
    
    $dvdFileInfo = Get-Item -Path $dvdPath
    $dvdDirName = $dvdFileInfo.DirectoryName
    $newDVDPath = "$dvdDirName\$containerName.Prototype.DVD.zip"
    $artifactFiles = "$dvdPath.TEMPDIR\" + ($dvdFileInfo.Name -replace $dvdFileInfo.Extension,'') + '\*'
    
    Write-Host "Compress prototype DVD : $newDVDPath" -ForegroundColor Cyan
    Compress-Archive -Path $artifactFiles -DestinationPath $newDVDPath 

    Write-Host "Assign New DVD Path: $newDVDPath" -ForegroundColor Cyan
    Write-Host ""
    $dvdPath = $newDVDPath
} 

#Create New Container
#####################
#Split the array
$artifactArray = $containerName.Split("-") 
#Set license file
$licenseVersion = $artifactArray[1]
$mylicense = "$licenseFolder\$licenseVersion.flf"
#Set country
$dvdCountry = $artifactArray[3].ToLower()

if ($artifactArray[0] -eq 'NAV') {

    if ($dvdPath -eq '') {

        [string]$artifactUrl = Get-NAVArtifactUrl -nav $artifactArray[1] -cu $artifactArray[2] -country $artifactArray[3].ToLower()
        if ($artifactUrl -eq '') {
            Write-Host "Artifact URL not found with the following parameters: $artifactArray"
            break
        }
        
        Write-Host "Targeting NAV : $artifactUrl" -ForegroundColor Cyan
        Write-Host ""

        New-BCContainer `
            -accept_eula `
            -containerName $containerName `
            -artifactUrl $artifactUrl `
            -Credential $credential `
            -auth UserPassword `
            -alwaysPull `
            -updateHosts `
            -useBestContainerOS  `
            -accept_outdated `
            -dns '8.8.8.8' `
            -doNotExportObjectsToText `
            -includeCSide
    }
    else {

        Write-Host "Targeting NAV DVD : $dvdPath" -ForegroundColor Cyan
        Write-Host ""

        New-BCContainer -accept_eula `
            -containerName $containerName `
            -licenseFile $mylicense `
            -dvdPath $dvdPath `
            -dvdCountry $dvdCountry `
            -Credential $credential `
            -auth NavUserPassword `
            -alwaysPull `
            -updateHosts `
            -useBestContainerOS  `
            -dns '8.8.8.8' `
            -doNotExportObjectsToText `
            -includeCSide
    }
}
else {
    if ($dvdPath -eq '') {

        $version = $artifactArray[1] + '.' + $artifactArray[2]
        [string]$artifactUrl = Get-BCartifactUrl -type $type -version $version -select latest -country $artifactArray[3].ToLower()
        if ($artifactUrl -eq '') {
            Write-Host "Artifact URL not found with the following parameters: $artifactArray"
            break
        }
        
        if (($artifactArray[1] -eq 14) -or ($artifactArray[1] -eq 13)) {
            Write-Host "Targeting hybrid BC $type : $artifactUrl" -ForegroundColor Cyan
            Write-Host ""
    
            New-BCContainer `
                -accept_eula `
                -containerName $containerName `
                -artifactUrl $artifactUrl `
                -Credential $credential `
                -auth UserPassword `
                -alwaysPull `
                -updateHosts `
                -licenseFile $mylicense `
                -accept_outdated `
                -doNotExportObjectsToText `
                -dns '8.8.8.8' `
                -includeCSide    
        }
        else {      
            Write-Host "Targeting BC $type : $artifactUrl" -ForegroundColor Cyan
            Write-Host ""

            New-BCContainer `
                -accept_eula `
                -containerName $containerName `
                -artifactUrl $artifactUrl `
                -auth NavUserPassword `
                -Credential $credential `
                -updateHosts `
                -accept_outdated `
                -useBestContainerOS `
                -alwaysPull `
                -assignPremiumPlan `
                -licenseFile $mylicense
                #-dns '8.8.8.8' `
        }
    }
    else {

        if (($artifactArray[1] -eq 14) -or ($artifactArray[1] -eq 13)){

            Write-Host "Targeting hybrid BC DVD : $dvdPath" -ForegroundColor Cyan
            Write-Host ""
    
            New-BCContainer -accept_eula `
            -containerName $containerName `
            -licenseFile $mylicense `
            -dvdPath $dvdPath `
            -dvdCountry $dvdCountry `
            -auth UserPassword `
            -Credential $credential `
            -accept_outdated `
            -alwaysPull `
            -updateHosts `
            -useBestContainerOS  `
            -dns '8.8.8.8' `
            -doNotExportObjectsToText `
            -includeCSide    
        }
        else {

            Write-Host "Targeting BC DVD : $dvdPath" -ForegroundColor Cyan
            Write-Host ""
    
            New-BCContainer -accept_eula `
                    -containerName $containerName `
                    -licenseFile $mylicense `
                    -dvdPath $dvdPath `
                    -dvdCountry $dvdCountry `
                    -Credential $credential `
                    -auth UserPassword `
                    -alwaysPull `
                    -updateHosts `
                    -useBestContainerOS `
                    -dns '8.8.8.8' 
        }
    }
}

#Create folder and move desktop shortcuts inside
$desktop = [System.Environment]::GetFolderPath('Desktop')
New-Item -Path $desktop -Name $containerName -ItemType 'directory' -Force
Get-ChildItem $desktop -Filter "$containerName*" -File | Move-Item -Destination "$desktop\$containerName"

$code = @'
[System.Runtime.InteropServices.DllImport("Shell32.dll")] 
private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);

public static void Refresh()  {
    SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);    
}
'@

Add-Type -MemberDefinition $code -Namespace WinAPI -Name Explorer 
[WinAPI.Explorer]::Refresh()

Flush-ContainerHelperCache -cache bcartifacts -keepDays 7
Flush-ContainerHelperCache -cache bakFolderCache -keepDays 7

