@ECHO off
	REM ____________=Development Info=____________
	REM Name: HomeScrew
	REM Version: 0.1.0
	REM Developed by Joris Van Duyse
	REM A Windows alternative to Homebrew!
	REM ===========================================
GOTO _introductionScript

:_introductionScript
	COLOR 0F
  ECHO Welcome to HomeScrew, the windows alternative for HomeBrew
  GOTO _prestarting

:_prestarting
	REM Will look for database version updates,
	REM if the latest version is installed
	REM and if all dependencies are installed
	COLOR 0C
	SETLOCAL EnableDelayedExpansion
	REM Not sure if I should disable this after use? oops
	for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"

	FOR /L %%n in (1,1,4) DO (
		REM disabled the spinner function because of explaination below!
		call :_spinner
    ping localhost -n 2 > nul
	)
	GOTO _getvariablescript

	REM The cute little script that turns the thingy
	:_spinner
		SET /a "spinner=(spinner + 1) %% 4"
		IF %spinner%==1 (
			IF EXIST .\dependencies (
				REM ECHO Confirm
			) ELSE (
					ECHO dependencies not found!
				SET _requirements=dependencies
				GOTO _installrequirements )
		)
		IF %spinner%==2 (
			IF EXIST .\database (
				REM ECHO Confirm
			) ELSE (
					ECHO database not found!
				SET _requiements=database
				GOTO _installrequirements )
		)
		IF %spinner%==3 (
			REM ECHO Confirm
			GOTO _settings
		)
		:_afterthree
		SET "spinChars=\|/-"
		<nul SET /p ".=Loading recources and applying settings !spinChars:~%spinner%,1!!CR!"
		exit /b

:_settings
	REM Settings that can be configured by the end user.
	GOTO :_afterthree

:_installrequirements
	ECHO Seems like your %_requirements% folder (and files) are missing!
	ECHO Would you like to download them?
	SET /p _downloadrequirements=(y / n):
	IF %_downloadrequirements%==y (
		ECHO Downloading requirements
		IF NOT EXIST .\dependencies MD .\dependencies
		REM Still have to program this in next patch
		IF NOT EXIST .\database (
			MD .\database
			curl https://raw.githubusercontent.com/Plaza-Development/HomeScrew/main/database/ProgramDatabase.txt > .\database\ProgramDatabase.txt
		)
		GOTO _prestarting
		)

	IF %_downloadrequirements%==n GOTO _forcedexit

:_getvariablescript
	COLOR 0A
	CLS
  ECHO Type help for more info
  SET /P _input=input:
  IF %_input%==help (
		GOTO _helpScript
	)
	IF %_input%==list ( GOTO _getlist
	) ELSE (GOTO _lookindatabase)

:_helpScript
  ECHO These are the following commands you can use:
  ECHO install [program name]: will install the given progam, if defined in database
  ECHO list: will give back a list of all currently available programs
  PAUSE
  GOTO _getvariablescript

:_getlist
	ECHO The download list:
	PAUSE
	GOTO _getvariablescript

:_lookindatabase
	REM /i: ignores the uppercase chars in input
 	for /f "tokens=1" %%a in ('findstr /I %_input% .\database\ProgramDatabase.txt') do (
	set _output=%%a
	) || GOTO _addtodatabase
	REM IF %_output%==NUL GOTO _addtodatabase
	GOTO _compilelink

:_compilelink
	REM Remove the program name from the database string (to get correct link)
	set _cutdownoutput=%_output:*_=%
	ECHO %_cutdownoutput%
	GOTO _downloadwithWget

:_downloadwithWget
	REM Downloads the given file from the link found in the ProgramDatabase.txt
	wget.exe -v --show-progress --append-output=download-log.txt --directory-prefix=TempDownloadFolder %_cutdownoutput%
	GOTO _installprebrief

:_installprebrief
	IF NOT EXIST .\TempDownloadFolder MD .\TempDownloadFolder
	IF NOT EXIST .\DownloadHistoryFolder MD .\DownloadHistoryFolder
	GOTO _installopt

:_installopt
	ECHO Install program in background or custom installation?
	SET /P _installchoice= (b / c):
	IF %_installchoice%==b GOTO _backgroundinstall (
		ELSE ( %_installchoice%==c GOTO _custominstall )
		ELSE
	)
	IF
	IF NOT %_installchoice%==c GOTO _installopt

:_custominstall
	COLOR 0C
	REM The custom install script allows for the user to install software at their
	REM own discretion

	CD .\TempDownloadFolder
	for /r "." %%a in (*.exe) do start "" "%%~fa"
	CD ..
	REM Above is ugly, so don't look

	ECHO Complete custom insallation before continuing!
	PAUSE

	REM Will clean up after installation is done
	GOTO _installdebrief


REM ____________________________STUCK AT DEVELOPING___________________________
:_backgroundinstall
	REM Option for the user to install the program in the background

	REM Temporarely replacing the background install with the custom one
	COLOR 0C
	ECHO Automated instlalation is not yet supported
	ECHO Will redirect to custom installation!
	PAUSE
	GOTO _custominstall

	REM Will clean up after installation is done
	REM GOTO _installdebrief
REM ---------------------------------------------------------------------------
REM seems like background installing is not possible, maybe future fix maybe not

:_installdebrief
	ECHO Moving installer to history folder
	MOVE .\TempDownloadFolder\* .\DownloadHistoryFolder\
	TIMEOUT /T 5

	REM All is done so go back to "start"
	GOTO _getvariablescript


:_addtodatabase
	ECHO %_input% does not exist in database or might be typed wrong
	PAUSE
	GOTO _getvariablescript

:_forcedexit
	ECHO Unable to run software without _requirements
