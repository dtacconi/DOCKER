Clear-Host
Write-Host 'Stop ALL Containers.............................................'
  docker stop $(docker ps -aq) 

Write-Host 'Delete ALL Containers...........................................'
docker rm -v $(docker ps -aq)

#Write-Host 'Force deletion of ALL Images....................................'
#docker rmi -f $(docker images -q)

Write-Host 'Uninstall old NavContainerHelper modules, please wait...'
Get-InstalledModule NavContainerHelper -AllVersions | Format-List -Property name, version 
Uninstall-Module NavContainerHelper -AllVersions -Force

Write-Host 'Uninstall all BCContainerHelper modules, please wait...'
Get-InstalledModule BCContainerHelper -AllVersions | Format-List -Property name, version 
Uninstall-Module BCContainerHelper -AllVersions -Force

Write-Host 'Delete ALL folders added through BCContainerHelper..............'
  $ProgramData = [System.Environment]::GetFolderPath('CommonApplicationdata')
  remove-item -Recurse "$ProgramData\BCContainerHelper\" -Force

Write-Host 'Delete ALL artifacts stored in the cache.........................'
  remove-item -Recurse -Force "C:\bcartifacts.cache\"

