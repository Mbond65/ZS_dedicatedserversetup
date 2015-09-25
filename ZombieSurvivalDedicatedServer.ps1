### Variables ####
$Exittext = "Press any key to exit"
$SteamCMDDownloadLocation = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$ZSDownloadLocation = "https://github.com/JetBoom/zombiesurvival/archive/master.zip"
$ULXDownloadLocation = "https://github.com/Nayruden/Ulysses/archive/master.zip"

### Print info ####
Write-Host "ZS Dedicated Server Install Script" -ForegroundColor Yellow
Write-Host "Version : 1.00" -ForegroundColor Yellow
Write-Host "Created by Mbond65" -ForegroundColor Yellow
Write-Host
####################

### Checking host ###
Write-Host "Testing Internet Connection..." -ForegroundColor Green -NoNewline
$Pingtest = Test-Connection -ComputerName "google.com" -Quiet 

if ($Pingtest -eq $true) 
{
    Write-Host "OK" -ForegroundColor Green
}
else
{
    Write-Host
    Write-Host "Ping test failed, the host which is running this script must be online. The script made ping requests to google.com which failed." -ForegroundColor Red
    Write-Host $Exittext -ForegroundColor Red
    Read-Host
    Exit
}

Write-Host "Testing Hard drive Space..." -ForegroundColor Green
Write-Host
Write-Host "Which drive would you like to install the server binaries on?" -ForegroundColor Yellow
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Free -ne 0} | Select -ExpandProperty Root
Write-Host
$Driveletter = Read-Host 
$Freespace = 0

while ($Driveletter.Length -ne 3)
{
    Write-Host "Please enter a drive letter (eg. C:\)" -ForegroundColor Red
    $Driveletter = Read-Host 
}

$Freespace = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -eq $Driveletter} | Select -ExpandProperty Free
$FreespaceGB = $Freespace /= 1073741824

if ($FreespaceGB -lt 5)
{
    Write-Host
    Write-Host "The drive (" $Driveletter ") selected to install the server on does not meet the 5GB space requirement or does not exist. The drive has " $FreespaceGB "GB of free space, please free some space up before running this script again." -ForegroundColor Red
    Write-Host $Exittext -ForegroundColor Red
    Read-Host
    Exit
}
Write-Host
Write-Host "Testing Hard drive Space...OK" -ForegroundColor Green
Write-Host "Testing SteamCMD Download link..." -ForegroundColor Green -NoNewline
$web = New-Object Net.WebClient
try
{
    $steamcmdData = $web.DownloadString($SteamCMDDownloadLocation)
}
catch
{
    Write-Host
    Write-Host "The download link for SteamCMD no longer works and will need to be changed, the site is not responding. Please edit the script and change the variable at the top for the SteamCMD download link, once it's been changed to something valid the script should function as intented." -ForegroundColor Red
    Write-Host $Exittext -ForegroundColor Red
    Read-Host
    Exit
}
Write-Host "OK" -ForegroundColor Green

Write-Host "Testing Zombie Survival Download link..." -ForegroundColor Green -NoNewline
$web = New-Object Net.WebClient
try
{
    $steamcmdData = $web.DownloadString($ZSDownloadLocation)
}
catch
{
    Write-Host
    Write-Host "The download link for Zombie Survival no longer works and will need to be changed, the site is not responding. Please edit the script and change the variable at the top for the SteamCMD download link, once it's been changed to something valid the script should function as intented." -ForegroundColor Red
    Write-Host $Exittext -ForegroundColor Red
    Read-Host
    Exit
}
Write-Host "OK" -ForegroundColor Green

Write-Host "Testing ULX Download link..." -ForegroundColor Green -NoNewline
$web = New-Object Net.WebClient
try
{
    $steamcmdData = $web.DownloadString($ULXDownloadLocation)
}
catch
{
    Write-Host
    Write-Host "The download link for ULX no longer works and will need to be changed, the site is not responding. Please edit the script and change the variable at the top for the SteamCMD download link, once it's been changed to something valid the script should function as intented." -ForegroundColor Red
    Write-Host $Exittext -ForegroundColor Red
    Read-Host
    Exit
}
Write-Host "OK" -ForegroundColor Green

####################

### SteamCMD Install ###
Write-Host "Please enter the path where you would like to install the server files? (Eg. C:\Steam)" -ForegroundColor Yellow
Write-Host
$SteamCMDInstallDir = Read-Host
$SteamCMDInstallDirExists = Test-Path $SteamCMDInstallDir

while ($SteamCMDInstallDirExists -eq $false)
{
    Write-Host "The path entered does not exist, please try again" -ForegroundColor Red
    $SteamCMDInstallDir = Read-Host
    $SteamCMDInstallDirExists = Test-Path $SteamCMDInstallDir
}

$SteamCMDDownloadLocationTemp = $SteamCMDInstallDir + "\temp.zip"
$SteamCMDownloadInstallLocation = $SteamCMDInstallDir + "\steamcmd.exe"
Write-Host
Write-Host "-----Installing SteamCMD-----" -ForegroundColor Green 
Write-Host
Write-Host "SteamCMD Downloading..." -ForegroundColor Green -NoNewline
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$Webclientdownloader = New-Object System.Net.WebClient
$Webclientdownloader.DownloadFile($SteamCMDDownloadLocation, $SteamCMDDownloadLocationTemp)
Write-Host "OK" -ForegroundColor Green

Write-Host "SteamCMD Extracting..." -ForegroundColor Green -NoNewline
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($SteamCMDDownloadLocationTemp, $SteamCMDInstallDir)
Start-Sleep 5
Write-Host "OK" -ForegroundColor Green

Write-Host "SteamCMD Installing..." -ForegroundColor Green -NoNewline
Start-Process -FilePath $SteamCMDownloadInstallLocation -Wait -ArgumentList "+quit"
Write-Host "OK" -ForegroundColor Green

Write-Host "SteamCMD Download Removed..." -ForegroundColor Green -NoNewline
Remove-Item -Path $SteamCMDDownloadLocationTemp
Write-Host "OK" -ForegroundColor Green
####################

### GMOD Install ###
Write-Host
Write-Host "-----Installing GMOD Dedicated Server-----" -ForegroundColor Green 
Write-Host
Write-Host "Where would you like the install Gmod? Please choose somewhere other than the directory where SteamCMD is installed (Eg. C:\Gmod)" -ForegroundColor Yellow
Write-Host
$GmodInstallDir = Read-Host
$GmodInstallDirExists = Test-Path $GmodInstallDir

while ($GmodInstallDirExists -eq $false)
{
    Write-Host "The path entered does not exist, please try again" -ForegroundColor Red
    $GmodInstallDir = Read-Host
    $GmodInstallDirExists = Test-Path $GmodInstallDir
}
Write-Host
Write-Host "Gmod Server Installing..." -ForegroundColor Green -NoNewline
Start-Process -FilePath $SteamCMDownloadInstallLocation -Wait -ArgumentList "+login anonymous +force_install_dir $GmodInstallDir +app_update 4020 -validate +quit"
Write-Host "OK" -ForegroundColor Green
####################

### ZS Install ###
Write-Host
Write-Host "-----Installing latest version of Zombie Survival-----" -ForegroundColor Green 
Write-Host
Write-Host "ZS Downloading..." -ForegroundColor Green -NoNewline
$Webclientdownloader = New-Object System.Net.WebClient
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$Webclientdownloader.DownloadFile($ZSDownloadLocation, $GmodInstallDir +"\temp.zip")
Write-Host "OK" -ForegroundColor Green

Write-Host "ZS Extracting..." -ForegroundColor Green -NoNewline
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($GmodInstallDir +"\temp.zip", $GmodInstallDir)
Start-Sleep 5
Write-Host "OK" -ForegroundColor Green

$GmodInstallDirRemove = $GmodInstallDir + "\temp.zip"
Write-Host "ZS Remove Download..." -ForegroundColor Green -NoNewline
Remove-Item -Path $GmodInstallDirRemove
Write-Host "OK" -ForegroundColor Green

$GmodMoveBefore =$GmodInstallDir + "\zombiesurvival-master\gamemodes\zombiesurvival"
$GmodMoveAfter = $GmodInstallDir + "\garrysmod\gamemodes\zombiesurvival"
Write-Host "ZS Copy to Gamemodes directory..." -ForegroundColor Green -NoNewline
Move-Item -Path $GmodMoveBefore -Destination $GmodMoveAfter
Write-Host "OK" -ForegroundColor Green

$GmodInstallDirRemove = $GmodInstallDir + "\zombiesurvival-master"
Write-Host "ZS Remove Extracted folder..." -ForegroundColor Green -NoNewline
Remove-Item -Path $GmodInstallDirRemove -Force -Recurse
Write-Host "OK" -ForegroundColor Green

####################

### ULX Install ###
Write-Host
Write-Host "-----Installing latest version of ULX-----" -ForegroundColor Green 
Write-Host "ULX Downloading..." -ForegroundColor Green -NoNewline
$Webclientdownloader = New-Object System.Net.WebClient
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$Webclientdownloader.DownloadFile($ULXDownloadLocation, $GmodInstallDir +"\temp.zip")
Write-Host "OK" -ForegroundColor Green

Write-Host "ULX Extracting..." -ForegroundColor Green -NoNewline
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($GmodInstallDir +"\temp.zip", $GmodInstallDir)
Start-Sleep 5
Write-Host "OK" -ForegroundColor Green

$GmodULXBefore = $GmodInstallDir + "\Ulysses-master\ulx"
$GmodULXAfter = $GmodInstallDir + "\garrysmod\addons"

Write-Host "ULX Move to addons..." -ForegroundColor Green -NoNewline
Move-Item -Path $GmodULXBefore -Destination $GmodULXAfter
Write-Host "OK" -ForegroundColor Green

$GmodULIBBefore = $GmodInstallDir + "\Ulysses-master\ulib"
$GmodULIBAfter = $GmodInstallDir + "\garrysmod\addons"

Write-Host "ULIB Move to addons..." -ForegroundColor Green -NoNewline
Move-Item -Path $GmodULIBBefore -Destination $GmodULIBAfter
Write-Host "OK" -ForegroundColor Green

$GmodInstallDirRemove = $GmodInstallDir + "\temp.zip"
Write-Host "ULX Remove Download..." -ForegroundColor Green -NoNewline
Remove-Item -Path $GmodInstallDirRemove
Write-Host "OK" -ForegroundColor Green

$GmodInstallDirRemove = $GmodInstallDir + "\Ulysses-master"
Write-Host "ULX Remove Extracted folder..." -ForegroundColor Green -NoNewline
Remove-Item -Path $GmodInstallDirRemove -Force -Recurse
Write-Host "OK" -ForegroundColor Green

####################

### Confirmation message ###

Write-Host
Write-Host "Success, all server components have been installed. To run the server you will need to navigate to " $GmodInstallDir " and type in a command such as: srcds.exe -console -game garrysmod +gamemode zombiesurvival +map gm_construct +maxplayers 4" -ForegroundColor Green
Write-Host
Write-Host "After testing you are able to connect to the server, the next task is setting up a server config file which can be done here: http://gmod-servercfg.appspot.com/" -ForegroundColor Green
Write-Host
Write-Host "Press any key to exit" -ForegroundColor Green
Read-Host
Exit
####################