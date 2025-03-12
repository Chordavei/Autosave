@echo off

:: Prints some fun ASCII art :D
echo                   #############                         
echo              ##################                         
echo           #####################                         
echo         ######################                          
echo       ########################           ####           
echo      #########################              ###         
echo    ##########################                 ##        
echo   ###########################          #       ##       
echo  ############################        #####      ##      
echo ########################       ############     ##      
echo #####################        ###############   ####     
echo ####################        ################     ##      
echo ##################        ################               
echo ##################      ##################               
echo #################     ##################                 
echo                    ##################                   
echo                 ###################    #################
echo               ###################     ##################
echo        #      #################       ##################
echo       ###      ##############       ####################
echo      ####        ##########       ##################### 
echo        #           ######      ######################## 
echo        ##            #    ############################  
echo         ##                ###########################   
echo          ###              ##########################    
echo            ###           #########################      
echo               ##         ########################       
echo                          ######################         
echo                         #####################           
echo                         ##################              
echo                         #############                              

:: Introduction to the installer
echo.
echo Autosave Installer
echo Made by Chordavei, lincensed under the GNU General Public 3.0 License
echo.

:: Checks if you already have Autosave installed
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ >nul 2>nul || reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\ /v AutosaveOnStartup >nul 2>nul
if %errorLevel% equ 0 (
	echo Autosave has already been installed on your computer, or you have registry values that indicate so
	echo If this is an error, use the repair tool or read how to manually remove the registry values and try again
	echo Do NOT attempt to remove values manually if you do not know what you are doing or have not read the guide
	echo.
	echo Press any key to exit the installer
	goto endScript
)

:: Checks if the installer is running with administartor permissions
reg add HKLM\SOFTWARE\Microsoft\Windows\AutosavePermissionCheck /ve /t REG_SZ /f > nul 2>nul
if not %errorLevel% equ 0 (
	echo You need to run the installer with admin permissions. Right click the installer and click "Run as administrator"
	echo Press any key to exit the installer
	goto endScript
)
reg delete HKLM\SOFTWARE\Microsoft\Windows\AutosavePermissionCheck /f > nul

:: User variables
:setDirectory
echo Enter your folder path with the files you want to backup:
set /p fileFolder=
if not exist %fileFolder% (
	echo.
	echo Your main folder cannot be found. Did you make sure the path is right?
	echo.
	goto setDirectory
)

:setBackup
echo Enter your backup folder path:
set /p backupFolder=
if not exist %backupFolder% (
	echo Your backup folder cannot be found. Did you make sure the path is right?
	echo.
	goto setBackup
)

:: Makes a dedicated directory to hold the program and make uninstalling it easier
if not exist "%userProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autosave\" (
	mkdir "%userProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autosave\"
)

:: Switches the active directory to the Startup folder
cd %userProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autosave"

:: Allows Autosave to run invisibly on startup
if not exist Autosave-Runtime.vbs (
	echo 'Creates the script to allow Autosave to run without popping up on your taskbar >> Autosave-Runtime.vbs
	echo Set WshShell = CreateObject("WScript.Shell"^) >> Autosave-Runtime.vbs
	echo WshShell.Run chr(34^) ^& "%localAppData%\Autosave\Autosave.bat" ^& Chr(34^), 0 >> Autosave-Runtime.vbs
	echo Set WshShell = Nothing >> Autosave-Runtime.vbs
)


:: Makes a directory to hold Autosave's files
if not exist "%localAppData%\Autosave\" (
	mkdir "%localAppData%\Autosave\"
)

:: Changes active directory to the folder
cd %localAppData%\Autosave\


:: Creates the bacth file that will back up your data
if not exist "%localAppData%\Autosave\Autosave.bat" (
	echo :: Autosave by Chordavei >> Autosave.bat
	@echo off >> Autosave-System.bat
	echo :: Copies the files and does nothing if files exist: >> Autosave.bat
	echo :loop >> Autosave-System.bat
	echo xcopy %fileFolder% %backupFolder% /D >> Autosave.bat
	echo. >> Autosave.bat
	echo :: Adjust timing to your liking. Default is every 15 seconds once. Remember that the longer you wait, the more of a theoretical chance you have to lose data >> Autosave.bat
	echo timeout /t 15 /nobreak >> Autosave.bat
	echo. >> Autosave.bat
	echo goto loop >> Autosave.bat
)

:: Creates the batch file for uninstalling Autosave
if not exist "%localAppData%\Autosave\Uninstall-Autosave.bat" (
	echo :: Autosave uninstaller >> Uninstall-Autosave.bat
	echo. >> Uninstall-Autosave.bat
	echo @echo off >> Uninstall-Autosave.bat
	echo :: Removes registry values >> Uninstall-Autosave.bat
	echo reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /f >> Uninstall-Autosave.bat
	echo reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run\ /v AutosaveOnStartup /f >> Uninstall-Autosave.bat
	echo. >> Uninstall-Autosave.bat
	echo :: Removes the directories used by the program (this will not affect the backups you have made^) >> Uninstall-Autosave.bat
	echo del /f /q %userProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autosave\ >> Uninstall-Autosave.bat
	echo rmdir /s /q %userProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autosave\ >> Uninstall-Autosave.bat
	echo start cmd /c cd %localAppData% ^>nul 2^>nul ^& ping 124.0.0.1 /n 1 /w 20 ^>nul 2^>nul ^& rmdir /s /q %localAppData%\Autosave\ ^& echo Autosave has successfully been uninstalled ^& echo Press any key to exit ^& pause ^>nul >> Uninstall-Autosave.bat
	echo del /f /q %AppData%\Local\Autosave\ /f >> Uninstall-Autosave.bat
)

:: Download the icon from GitHub. If you don't have internet during the installation, the icon will not download but everything will still work
curl -s -O https://raw.githubusercontent.com/Chordavei/Autosave/main/Images/Autosave-Icon.ico > nul 2>nul

:: Adds the registry key to start backing up on startup
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\ /v AutosaveOnStartup /t REG_SZ /d ^"%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autosave\Autosave-Runtime.vbs^" >nul 2>nul

:: Adds registry keys to define Autosave as an application on your PC to allow it to show up in Settings > Apps > Installed apps
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v DisplayName /t REG_SZ /d Autosave /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v Publisher /t REG_SZ /d Chordavei /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v UninstallString /t REG_SZ /d %localAppData%\Autosave\Uninstall-Autosave.bat /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v NoModify /t REG_DWORD /d 1 /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v NoRepair /t REG_DWORD /d 1 /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v URLInfoAbout /t REG_SZ /d https://github.com/Chordavei/Autosave /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v DisplayIcon /t REG_SZ /d %localAppData%\Autosave\Autosave-Icon.ico /f >nul 2>nul
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Autosave\ /v EstimatedSize /t REG_DWORD /d 188 /f >nul 2>nul

echo.
echo Autosave has been installed on your system! Reboot to start backing up your data
echo If you find this tool useful, please star the Autosave GitHub repository!
echo.
echo Press any key to exit the installer

:endScript
pause >nul