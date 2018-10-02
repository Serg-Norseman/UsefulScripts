rem Copyright (C) 2016 by Sergey Zhdanovskih <serg.zhdanovskih@gmail.com>.
rem License: MIT License (https://opensource.org/licenses/MIT).

@echo off
cls
SETLOCAL ENABLEDELAYEDEXPANSION

md ".\backup"

set /a count=0

for %%f in (.\news\*.pdi) do (
    	set fn=%%~nxf
	set wfn=.\work\!fn!

	rem echo File: !fn!
	rem echo Work file: !wfn!

	if exist !wfn! (
		set /a count+=1

		xcopy /Q "!wfn!" ".\backup\"
	)
)
echo Backup %count% changed files
pause
