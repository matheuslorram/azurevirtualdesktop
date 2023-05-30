$FilesFolder = 'C:\Files'
New-Item -ItemType Directory -Path $FilesFolder


$webClient = New-Object System.Net.WebClient
$wvdAgentInstallerURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$wvdAgentInstallerName = 'WVD-Agent.msi'
$webClient.DownloadFile($wvdAgentInstallerURL,"$FilesFolder/$wvdAgentInstallerName")
$wvdBootLoaderInstallerURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$wvdBootLoaderInstallerName = 'WVD-BootLoader.msi'
$webClient.DownloadFile($wvdBootLoaderInstallerURL,"$FilesFolder/$wvdBootLoaderInstallerName")



[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name PowerShellGet -Force -SkipPublisherCheck


Install-Module -Name Az.DesktopVirtualization -AllowClobber -Force
Install-Module -Name Az -AllowClobber -Force



Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
Connect-AzAccount -TenantId cab1ba99-21e0-4a40-8f98-aef71b9b0f80

$resourceGroupName = 'rg-avd-hml'
$hostPoolName = 'PoolDEVPS'
$registrationInfo = New-AzWvdRegistrationInfo -ResourceGroupName $resourceGroupName -HostPoolName $hostPoolName -ExpirationTime $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))

Set-Location -Path $FilesFolder
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $WVDAgentInstallerName", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$($registrationInfo.Token)", "/l* $FilesFolder\AgentInstall.log" | Wait-Process
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $wvdBootLoaderInstallerName", "/quiet", "/qn", "/norestart", "/passive", "/l* $FilesFolder\BootLoaderInstall.log" | Wait-process


