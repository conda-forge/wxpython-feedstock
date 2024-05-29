@echo on
setlocal EnableDelayedExpansion

:: The wxpython build system searches for wxwidgets library files
:: and the wx/setup.h file in ext/wxWidgets/lib/vc<msvc_ver>_x64_dll
:: where <msvc_ver> is the integer component of the vc version
:: multiplied by 10. See:
::
::  - the getVisCVersion() function in buildtools/config.py
::  - the getMSWSettings() function in build.py
xcopy /y /e /s  %PREFIX%\Library\lib\vc_x64_dll ext\wxWidgets\lib\vc140_x64_dll\
if errorlevel 1 exit 1

:: The siplib files contained in the 4.2.1 tarball are incompatible
:: with python 3.12, so need to be re-generated
:: https://github.com/wxWidgets/Phoenix/issues/2455
"%PYTHON%" build.py sip      --no_magic --use_syswx --prefix="%PREFIX%" --jobs="%CPU_COUNT%"
if errorlevel 1 exit 1

"%PYTHON%" build.py build_py install_py --no_magic --use_syswx --prefix="%PREFIX%" --jobs="%CPU_COUNT%" --extra_make="-v" --verbose
if errorlevel 1 exit 1
