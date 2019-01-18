echo "Copying libs and headers"

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%
if not exist "%LIBRARY_BIN%" mkdir %LIBRARY_BIN%

REM copy .lib and .pdb files to LIBRARY_LIB and .dll to LIBRARY_BIN
copy ext\wxWidgets\lib\vc140_dll\*.lib %LIBRARY_LIB%
copy ext\wxWidgets\lib\vc140_dll\*.dll %LIBRARY_BIN%
copy ext\wxWidgets\lib\vc140_dll\*.pdb %LIBRARY_LIB%

REM copy .h files to LIBRARY_INC
mkdir %LIBRARY_INC%\wx
xcopy /y /e ext\wxWidgets\include\wx %LIBRARY_INC%\wx
mkdir %LIBRARY_INC%\wx\msw
xcopy /y /e ext\wxWidgets\lib\vc140_dll\mswu\wx\msw %LIBRARY_INC%\wx
copy ext\wxWidgets\lib\vc140_dll\mswu\wx\setup.h %LIBRARY_INC%\wx\setup.h
