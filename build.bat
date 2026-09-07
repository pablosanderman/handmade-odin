@echo off
setlocal

pushd "%~dp0"

where odin >nul 2>&1
if errorlevel 1 (
    echo Odin was not found on PATH.
    popd
    exit /b 1
)

if not exist "build" mkdir "build"

odin build . -out:"build\handmade_odin.exe" -pdb-name:"build\handmade_odin.pdb" -debug
if errorlevel 1 (
    set "handmade_exit_code=%errorlevel%"
    popd
    exit /b %handmade_exit_code%
)

if /i "%~1"=="build" goto done
if /i "%~1"=="debug" goto debug

"build\handmade_odin.exe"
set "handmade_exit_code=%errorlevel%"
popd
exit /b %handmade_exit_code%

:debug
set "rad_debugger=%RADDBG_EXE%"
if not defined rad_debugger if exist "C:\programs\raddbg.exe" set "rad_debugger=C:\programs\raddbg.exe"
if not defined rad_debugger if exist "%USERPROFILE%\Downloads\raddbg.exe" set "rad_debugger=%USERPROFILE%\Downloads\raddbg.exe"
if not defined rad_debugger for /f "delims=" %%I in ('where raddbg 2^>nul') do if not defined rad_debugger set "rad_debugger=%%I"

if not defined rad_debugger (
    echo RAD Debugger was not found on PATH.
    popd
    exit /b 1
)

tasklist /fi "imagename eq raddbg.exe" 2>nul | find /i "raddbg.exe" >nul
if not errorlevel 1 (
    echo RAD Debugger is already open. Close it, then run the Debug build again to open Handmade Odin.
    popd
    exit /b 0
)

start "" "%rad_debugger%" "%CD%\handmade-odin.raddbg"

:done
popd
