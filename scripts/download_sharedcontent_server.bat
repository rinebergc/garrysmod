@echo off
set "sharedcontent=C:\garrysmod\sharedcontent"

rem Comments have been added to provide clarity and educational value where possible.
rem For more information on Powershell cmdlets see: https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1.
rem For more information on SteamCMD see: https://developer.valvesoftware.com/wiki/SteamCMD, https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD, and https://developer.valvesoftware.com/wiki/Steam_Application_IDs.
rem For more information on Windows commands see: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands.

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
rem This script requires SteamCMD to function. Check for it and continue if it's present. Otherwise, download it.



set /p account="PLEASE ENTER YOUR STEAM USERNAME: "
:MENU
cls
echo Username: %account% 
echo 0 - Enter a new username.
echo.
echo Install/Update:
echo.
echo 1 - HL2 + EP1 + EP2
echo 2 - CS:S
echo 3 - TF2
echo 4 - ALL
echo 5 - QUIT
echo.
set /p input="PLEASE ENTER 0, 1, 2, 3, OR 4: "
rem Create a text-based interface to control the script.

if %input%==0 ^
cls ^
&& set /p account="PLEASE ENTER YOUR STEAM USERNAME: " ^
&& goto MENU
rem Re-prompt the user for their Steam username.

if %input%==1 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login %account% +force_install_dir %temp%\steamcmd\ep2 +app_update 420 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\hl2" "%sharedcontent%\hl2" "*.vpk" ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\episodic" "%sharedcontent%\episodic" "*.vpk" ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\ep2" "%sharedcontent%\ep2" "*.vpk" ^
&& goto MENU
rem Download HL2:EP2 (Contains HL2, HL2:EP1, HL2:EP2).

if %input%==2 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\steamcmd\cstrike +app_update 232330 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\cstrike\cstrike" "%sharedcontent%\cstrike" "*.vpk" ^
&& goto MENU
rem Download CS:S.

if %input%==3 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\steamcmd\tf +app_update 232250 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\tf\tf" "%sharedcontent%\tf" "*.vpk" ^
&& goto MENU
rem Download TF2.

if %input%==4 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login %account% +force_install_dir %temp%\steamcmd\ep2 +app_update 420 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\hl2" "%sharedcontent%\hl2" "*.vpk" ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\episodic" "%sharedcontent%\episodic" "*.vpk" ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\ep2" "%sharedcontent%\ep2" "*.vpk" ^
&& start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\steamcmd\cstrike +app_update 232330 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\cstrike\cstrike" "%sharedcontent%\cstrike" "*.vpk" ^
&& start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\steamcmd\tf +app_update 232250 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\tf\tf" "%sharedcontent%\tf" "*.vpk" ^
&& goto MENU

if %input%==5 ^
del /q %temp%\steamcmd.zip ^
& rmdir /s /q %temp%\steamcmd ^
& exit
rem Cleanup - Remove temporary files and directories.
