@echo off & SETLOCAL ENABLEDELAYEDEXPANSION
cls

set osql="PATH_TO_OSQL_COMMAND_LINE"

set DEV="SERVER_NAME|USER_ID|PASSWORD|DB_NAME"
set QA="SERVER_NAME|USER_ID|PASSWORD|DB_NAME"
set UAT="SERVER_NAME|USER_ID|PASSWORD|DB_NAME"
set PP="SERVER_NAME|USER_ID|PASSWORD|DB_NAME"
set PROD="SERVER_NAME|USER_ID|PASSWORD|DB_NAME"
 
SET script=%1
SET sql="%2"
echo Executing script %script%
 
:INIT
echo.
echo Please select TARGET environment:
echo.
CALL :REGION 1 DEV
CALL :REGION 2 QA
CALL :REGION 3 UAT
CALL :REGION 4 PP
CALL :REGION 5 PROD
echo.
echo [q] Exit
echo.
 
set /P work_area=Enter your Choice:
if "%work_area%" == "1" CALL :INITVAR DEV
if "%work_area%" == "2" CALL :INITVAR QA
if "%work_area%" == "3" CALL :INITVAR UAT
if "%work_area%" == "4" CALL :INITVAR PP
if "%work_area%" == "5" CALL :INITVAR PROD
if /I "%work_area%" == "q" goto EXIT
goto EXIT
 
:REGION
FOR /F "tokens=1-1 delims=|" %%i IN (!%2!) DO echo [%1] %2  ^(%%i^)
goto :eof
 
:INITVAR
set REGION=%1
FOR /F "tokens=1-4 delims=|" %%i IN (!%1!) DO (
                set SERVER=%%i
                set USER=%%j
                set PASSWD=%%k
                set DB=%%l
)
goto SQL
 
:SQL
echo.
echo Running the script in %REGION% Region (%SERVER%.%DB%)
echo.
if %sql% == "sql" (
                set queryopt=-Q
) else (
                set queryopt=-i
)
if %PASSWD% == . (
                set passwdopt=-E
) else (
                set passwdopt=-P %PASSWD%
)

%osql% -S %SERVER% -U %USER% %passwdopt% -d %DB% %queryopt% %script% -s "|" -n -m-1 -r 1 -w 65536
goto END
 
:END
set work_area=.
goto INIT
 
:EXIT
pause
exit