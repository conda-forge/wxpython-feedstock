echo "Installing wxWidgets"

setlocal EnableDelayedExpansion

REM identify wxWidgets lib build subdirectory
set "wx_lib_path="
FOR /D %%F IN (ext\wxWidgets\lib\vc*) DO (
	IF [!wx_lib_path!] EQU [] (
		set wx_lib_path=%%F
	) ELSE (
		echo "Found multiple matches for ext\wxWidgets\lib\vc*"
		exit 1
	)
)

IF [%wx_lib_path%] EQU [] (
	echo "Didn't find vc lib subdir matching ext\wxWidgets\lib\vc*"
	exit 1
)

echo "wx_lib_path:%wx_lib_path%"

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
if errorlevel 1 exit 1
if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%
if errorlevel 1 exit 1
if not exist "%LIBRARY_BIN%" mkdir %LIBRARY_BIN%
if errorlevel 1 exit 1


REM copy .lib and .pdb files to LIBRARY_LIB and .dll to LIBRARY_BIN
copy %wx_lib_path%\*.lib %LIBRARY_LIB%
if errorlevel 1 exit 1
copy %wx_lib_path%\*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1
copy %wx_lib_path%\*.pdb %LIBRARY_LIB%
if errorlevel 1 exit 1


REM copy .h files to LIBRARY_INC
mkdir %LIBRARY_INC%\wx
if errorlevel 1 exit 1
xcopy /y /e ext\wxWidgets\include\wx %LIBRARY_INC%\wx
if errorlevel 1 exit 1
if not exist "%LIBRARY_INC%\wx\msw" mkdir %LIBRARY_INC%\wx\msw
if errorlevel 1 exit 1
xcopy /y /e %wx_lib_path%\mswu\wx\msw %LIBRARY_INC%\wx
if errorlevel 1 exit 1
copy %wx_lib_path%\mswu\wx\setup.h %LIBRARY_INC%\wx\setup.h
if errorlevel 1 exit 1
