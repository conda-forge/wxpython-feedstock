setlocal EnableDelayedExpansion

"%PYTHON%" build.py build_wx --no_magic --prefix="%PREFIX%" --jobs="%CPU_COUNT%"
if errorlevel 1 exit 1
call "%RECIPE_DIR%"\install_wxwidgets.bat
if errorlevel 1 exit 1

"%PYTHON%" -c "f = open('./ext/wxWidgets/include/wx/msw/wx.rc', 'r'); txt = f.readlines(); f.close(); txt[124] = '#define wxMANIFEST_CPU amd64'; txt[123] = '#define WX_CPU_AMD64'; f = open('./ext/wxWidgets/include/wx/msw/wx.rc', 'w'); f.writelines(txt); f.close()"

"%PYTHON%" build.py build_py install_py --no_magic --prefix="%PREFIX%" --jobs="%CPU_COUNT%" --extra_make="-v" --verbose
if errorlevel 1 exit 1
