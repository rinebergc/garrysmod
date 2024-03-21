@echo off

set steamcmdCheck= ^
if (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) { ^
} elseif (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) { ^
	Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd ^
} elseif (Test-Path -Path %temp%\steamcmd.exe -PathType leaf) { ^
	if (-not (Test-Path -Path %temp%\steamcmd -PathType container)) {New-Item -ItemType directory -Path %temp%\steamcmd} ^
	Move-Item -Path %temp%\steamcmd.exe -Destination %temp%\steamcmd\steamcmd.exe ^
} else { ^
	(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); ^
	Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd ^
}
powershell -command "%steamcmdCheck%"
rem For more information on SteamCMD see: https://developer.valvesoftware.com/wiki/SteamCMD, https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD, and https://developer.valvesoftware.com/wiki/Steam_Application_IDs.

set "folderPicker="(new-object -COM 'Shell.Application').BrowseForFolder(0,'Please select DRIVE:\Program Files (x86)\Steam\steamapps\common\GarrysMod.',0,0).self.path""
for /f "usebackq delims=" %%I in (`powershell -command %folderPicker%`) do set "clientDir=%%I"

start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\steamcmd\cstrike +app_update 232330 validate +quit
start /b /wait robocopy "%temp%\steamcmd\cstrike\cstrike" "%clientDir%\garrysmod\addons\cstrike" "*.vpk"

wmic process where "ExecutablePath='%clientDir:\=\\%\\hl2.exe'" call terminate
> "%clientDir%\garrysmod\cfg\mount.cfg" (
	echo "mountcfg"
	echo {
	echo "cstrike"  "%clientDir%\garrysmod\addons\cstrike"
	echo }
)
> "%clientDir%\garrysmod\cfg\mountdepots.txt" (
	echo "gamedepotsystem"
	echo {
	echo "cstrike"  "1"
	echo }
)


if exist %temp%\steamcmd.zip del /q %temp%\steamcmd.zip
if exist %temp%\steamcmd\ rmdir /s /q %temp%\steamcmd