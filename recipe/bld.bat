@echo on
setlocal EnableDelayedExpansion

:: The siplib files contained in the 4.2.1 tarball are incompatible
:: with python 3.12, so need to be re-generated
:: https://github.com/wxWidgets/Phoenix/issues/2455
"%PYTHON%" build.py sip      --no_magic --use_syswx --prefix="%PREFIX%" --jobs="%CPU_COUNT%"

if errorlevel 1 exit 1

"%PYTHON%" build.py build_py install_py --no_magic --use_syswx --prefix="%PREFIX%" --jobs="%CPU_COUNT%" --extra_make="-v" --verbose
if errorlevel 1 exit 1
