@echo off

:: Setting up current path in variable
setlocal enableextensions
set current_path=%~dp0

goto :main


:check_admin_permission
	:: Checking if current user has appropriate rights :)
	net session >nul 2>&1

	:: If current user is admin, let's set the role as AdminUser
	if %errorLevel% == 0 (
		set %~1=AdminUser
	)
goto :eof


:set_configuration
	:: Setting up window (Later it will be changed to what is configured in settings file)
	title "Database Deployment Tool"
goto :eof


:reconfiguration
	color %~1
	
	:: No need to reset the window size if mode is DEFAULT
	if not "%~2" == "DEFAULT" (
		mode con: cols=55 lines=7
	)
goto :eof


:show_message
	set messageType=%~1
	set messageTitle=%~2
	set messageText=%~3
	set windowMode=%~4

	:: Lets clear the screen before showing any message
	cls

	:: Configuration for message type Error
	if /i "%messageType%" == "ERROR" (
		call :reconfiguration "B" %windowMode%
	)

	:: Configuration for message type Success
	if /i "%messageType%" == "SUCCESS" (
		call :reconfiguration "B" %windowMode%
	)

	:: Configuration for message type Info
	if /i "%messageType%" == "INFO" (
		call :reconfiguration "B" %windowMode%
	)

	if /i "%messageType%" == "INFO" (
		set windowTitle=%messageTitle%
	) else (
		set windowTitle=%messageType% - %messageTitle%
	)

	title %windowTitle%
	echo ======================================================
	echo                  %messageTitle%
	echo ======================================================
	echo.
	echo  %messageText%
	echo.
	
	REM To pause the screen for 3 seconds
	timeout 10 > nul
goto :eof


:: Fun starts here
:main
	set user_role=LocalUser

	:: Setting up batch file configuration
	call :set_configuration

	:: Checking for user permission
	call :check_admin_permission user_role
	
	:: If user has proper permission let's go ahead
	if "%user_role%" == "AdminUser" (
		
		:: In case of Deployment script is moved or removed 
		if not exist "%current_path%Deployment.ps1" (
			call :show_message "ERROR" "Something Is Broken" "Not able to locate deployment script (Deployment.ps1)"
		) else (
			:: Showing message for Compitibility
			call :show_message "INFO" "Compatibility Check" "Checking module Compatibility..." "DEFAULT"
			
			:: checking if Invoke-SqlCmd is available or not
			powershell.exe -Command "& { if (Get-Command Invoke-SqlCmd -ErrorAction SilentlyContinue) { 'CommandAvailable' | Out-File -FilePath $env:temp'\SQLCmdLetAvailable.log' } }"
			
			if exist "%temp%\SQLCmdLetAvailable.log" (

				:: Deleting CmdLet Check file before proceding further
				if exist "%temp%\SQLCmdLetAvailable.log" (
					del "%temp%\SQLCmdLetAvailable.log"
				)

				:: Changing Directory where deployment script is located
				cd /d %current_path%

				:: Lets clear the screen first
				cls

				:: Lets start a real fun
				powershell.exe -ExecutionPolicy Bypass -File "Deployment.ps1"

				:: Its Done moment
				echo.
				set /p press_any_key=Press any key to close...
				echo.
			) else (
				call :show_message "ERROR" "Not Yet Ready" "SORRY.. Required module is not available..." 
			)
		)
	) else (
		call :show_message "ERROR" "Insufficient Permission" "Insufficient Permission... Try it with Run As Admin..." 
	)
goto :eof