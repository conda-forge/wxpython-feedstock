"%PYTHON%" build.py build_wx install_wx --no_magic --prefix="%PREFIX%" --jobs="%CPU_COUNT%"
if errorlevel 1 exit 1
"%PYTHON%" build.py build_py install_py --no_magic --prefix="%PREFIX%" --jobs="%CPU_COUNT%"
if errorlevel 1 exit 1